# 预处理器扩展 (Pre-Processor eXtension)


OCaml 的编译器 ocamlc 和 ocamlopt 在编译阶段提供 -pp 选项来预处理文件（但请记住，建议使用 Dune 来驱动预处理）

PPX 不运行在文本源代码上，而是运行在解析结果上：抽象语法树（AST），在 OCaml 编译器中称为 Parsetree.

PPX 运行在 Parsetree 上，这是 OCaml 解析的结果

(什么叫做 运行在文本源代码上? 即类似 C 的宏，文本替换; 而 PPX 更像是 Rust 的宏)


## 组成

PPX 系统由三个部分组成:

1. 编译器中的钩子
2. ppxlib
3. 单独的 PPX 重写器


其本质是: 编译器中的钩子允许 ppxlib 插入 编译的过程中，并根据用户指定的 ppx 重写列表对输入文件进行重写. 这些钩子以命令行标志的形式出现，执行命令即可执行.



`源代码 (.ml) --> 解析 (Parsing) --> AST --> 类型检查 --> 编译`

所谓的“钩子”，就是编译器在 “解析” 完成后，故意停下来，开启一个窗口，允许外部程序进来修改 AST. 开启这个窗口的命令行参数有两个 `-pp` 和 `-ppx`.

**`-pp`**: 
    输入： 源代码文本.
    输出： 源代码文本 或 序列化的 AST.
    原理： 编译器在解析代码之前，先调用 `-pp` 指定的程序（如 sh 脚本、camlp4 或 m4）读取你的 .ml 文件，修改字符串内容，然后把修改后的文本还给编译器.

        例子:

        ```sh
        # preprocessor.sh
        sed 's/World/Universe/g' $1   
        ```

        ```ml
        (* hello.ml *)
        print_endline "Hello, World!";;
        ```

        执行 `ocamlopt -pp ./preprocessor.sh hello.ml` 得到:

        ```ml
         (* hello.ml *)
        print_endline "Hello, Universe!";; 
        ```
    缺点:  只是简单的文本替换类似 C 的宏，它不理解 OCaml 语法，容易导致行号错乱或语法破坏. 如: 字符串有多个分隔符（如 {| ...|}），换行符或注释可能会导致混乱.

**`-ppx`**: 
    输入： AST (抽象语法树).
    输出： 修改后的(另一个) AST.
    原理： 编译器先自己解析 .ml 文件得到 AST，然后把这个 AST 序列化传给 -ppx 程序. PPX 程序（如 my_rewriter.exe）修改这个树结构，再传回给编译器.

        ```ml
        (* 编写 AST 重写器规则: my_ppx.ml *)
        open ppxlib

        (* 1. 这是核心逻辑：输入是一个 payload，输出是一个 AST 表达式节点 *)
        (* 定义转换逻辑：把 [%get_time] 变成 "2025" *)
        let expand ~ctxt payload =
          let loc = Expansion_context.Extension.derived_item_loc ctxt in
          (* Ast_builder 会帮你生成 OCaml 的 AST 节点 *)
          Ast_builder.Default.estring ~loc "2025-12-22"

        (* 2. 注册钩子：告诉编译器碰到 [%get_time] 就调用 expand *)
        let my_extension =
          Context_free.Rule.extension
            (Extension.V3.declare
               "get_time"                      (* 扩展点的名字 *)
               Extension.Context.expression    (* 它出现在表达式位置，如 let date = [%get_time] *)
               Ast_pattern.(pstr nil)          (* 不带参数 *)
               expand)

        (* 3. 注册这个转换规则 *)
        let () =
          Driver.register_transformation ~rules:[my_extension] "time_ppx"
        ```

        将 my_ppx.ml 编译成可执行稳文件 (通过 dune 处理)

        ```dune
        (library
            (name my_time_ppx)  ; 执行 dune buile 生成二进制的名称
            (kind ppx_rewriter) ; 关键：告诉 Dune 这是一个 PPX 重写器
            (libraries ppxlib)) ; 依赖 ppxlib
        ```

        执行: dune build ./my_time_ppx.exe 在当前目录生成 my_time_ppx.exe (如果只执行 dune build 则文件生成的路径在 _build/default/my_time_ppx.exe)

        ```ml
        (* 编写 app.ml *)
        let date = [%get_time]
        let () = print_endline date
        ```

        执行: `ocamlc -I +unix -dsource -ppx "./my_time_ppx.exe" app.ml` 其中 `-I +unix` 表示帮插件或业务代码去标准库目录下的 unix 子目录 ./ 中查找 `my_time_ppx.exe` 文件、`-dsource` 表示查看转换后的源代码. 最后得到:

        ```ml
        (* 最终的 app.ml *)        
        let date = "2025-12-22"
        let () = print_endline date
        ```

    优点：它理解代码逻辑，不会破坏代码结构，支持强大的语法扩展.


**编译器中的钩子** 和 **ppxlib** 和 **PPX 重写器** 三者协作作用才能发挥作用的:

1. 用户：在 dune 中写下 (preprocess (pps my_ppx))。
2. Dune (构建工具)：调用编译器钩子（-ppx），并将所有相关的 个人 PPX 重写器 链接成一个单一的可执行文件（基于 ppxlib）。
3. 编译器：解析代码生成 AST，将其通过管道发给这个可执行文件。
4. ppxlib：接收 AST，扫描其中的扩展点（如 % 开头的标识符），分发给对应的个人重写器函数。
5. 个人重写器：将特定的语法糖替换为真正的 OCaml 代码（AST 节点）。
6. 编译器：拿到最终的代码，完成编译。

**它们协同作用的“生命周期”**

为了让你看清这种协同，我们看这三个部分在编译中是如何交换数据的：

准备阶段（ppxlib + 重写器）：

    你写的重写器源码调用 ppxlib 提供的 API。dune 把它们揉在一起，编译出一个能独立运行的二进制文件 my_ppx.exe。
  *(此时，ppxlib 已经住进了你的 .exe 里面)*

启动阶段（编译器钩子）：

    你输入 `ocamlc -I +unix -dsource -ppx "./my_time_ppx.exe" app.ml` 时，编译器钩子启动了，它把 app.ml my_time_ppx.exe，接球！”

处理阶段（ppxlib 内部）：

    数据进入 my_ppx.exe。此时 ppxlib 接管了控制权：1. 它先把编译器丢过来的球（原始 AST）翻译成标准格式。2. 它带着这棵树，在你的重写器逻辑里转了一圈，把该改的地方全改了。3. 它再把改好的树翻译回编译器认识的格式。

收尾阶段（编译器钩子）：

    编译器钩子收到了 my_time_ppx.exe 吐回来的球（改好的 AST），关上大门，继续进行类型检查和后面的编译。


|      部分       |  角色   |           一句话形容                                     |
| ---------------|---------|---------------------------------------------------------|
|    编译器钩子   | 连接者   |      提供 `-pp` 和 `-ppx` 接口，负责 “递 AST” 和 “接 AST” |
|    ppxlib      | 管理器   |      向上对接编译器，向下提供工具箱，统一管理 AST 转换      |
|    个人重写器   | 执行者   |      具体的逻辑实现。它建立在 ppxlib 之上，决定最终变成代码 |


## 类型


```ml
(* 
如: %name payload、 %%name payload、 @name payload、 @@name payload、@@@name payload 等等
*)
```


**% (表示拓展点)** 这里要变魔术（代码替换） 
    语法树的“空洞”，必须被替换成合法的 OCaml 代码才能通过编译

**@ (表示属性)**   给代码贴个标签（代码注释/修饰）
    代码的“元数据”，修饰已有的代码，插件读取它来决定行为

### % 拓展点


**语法:  `%name payload` 和 `%%name payload`**

扩展节点是语法树中的 “洞”. 解析器在很多地方都接受它们，比如模式、表达式、核心类型或模块类型. 要判断某个位置是否允许扩展节点，你可以查看解析树，看看对应节点是否有扩展构造子. 然而，扩展节点会被编译器随后拒绝. 因此， 必须通过 PPX 重写它们才能继续编译.

(其中, 扩展器是一种 PPX 重写器，会用匹配的名称替换 所有扩展节点 的出现)


常见的 扩展节点 用法示例:

在 `*.ml` 文件中:

```ml
(* 表达式作为拓展节点 *)
let v = [%html "<a href='ocaml.org'>OCaml!</a>"]

(* let 语句块作为拓展节点 *)
[%%html let v = "<a href='ocaml.org'>OCaml!</a>"]



(* 
当扩展节点和 payload 类型相同时，可以使用更短的中缀语法

该语法要求扩展节点的名称必须附加在定义块的关键词上（例如 let、begin、module、val 等），
如: let%html 写法, let 和 %name 紧紧地贴在一起
并且 等价于整个区块被包裹在有效载荷中
*)
(* 语法等价于 [%%html let v = ...] *)
let%html v = "<a href='ocaml.org'>OCaml!</a>"
```

而在 `*.mli` 中, payload 是类型签名

```ml
(* 两个相等的语法, 类型签名作为 拓展节点 *)
[%ext_name: val foo : unit]
val%ext_name foo : unit


(* 一个模式匹配作为 拓展节点, 如匹配 a :: _ 类型的 list *)
let [%ext_name? a :: _ ] = ()
```


**什么时候用 %？**

当你想要实现 OCaml 语言本身做不到的语法时。

  例如：`let%lwt` 处理异步逻辑，它把后面的代码全部包进了回调函数里。这涉及到代码结构的重组。




1. **%** : 表示 内部节点 (用于替换一小部分内容), 如: 表达式 、 类型 和 模式 (级别)


```ml
(* 表达式扩展：编译时读取环境变量 ppx_env JaneStreet 提供 *)
(* 
    假设执行编译时 HOME 的值是 /home/user, 展开后的代码应为:

        let x = "/home/user"
 *)
let x = [%env "HOME"]        

(* 模式扩展：用于复杂的正则匹配解构   ppx_regexp 提供 *)
(* 
    展开后:

        (* 1. PPX 自动在隐藏位置生成预编译对象 *)
        let __ppx_regex_1 = Re.Pcre.regexp "(\\d+)"

        (* 2. 原代码行会被展开为类似以下的逻辑 *)
        let id = 
          match Re.Pcre.exec ~rex:__ppx_regex_1 "123" with
          | groups -> Re.Pcre.get groups 1  (* 提取第一个捕获组 *)
          | exception Not_found ->  raise (Match_failure ("your_file.ml", line, col))

*)
let [%regex {|(\d+)|}] id = "123" 

(* 类型扩展：动态生成类型 (自定义的, 需要写重写器代码) *)
(* 
    展开后代码依赖于自己写的重写器逻辑
*)
type t = [%custom_type]           


(* 
常见的库 :
    ppx_expect, ppx_let, ppx_inline_test  由 JaneStreet 提供
*)

(* ppx_expect 用法 *)
let%expect_test "addition" =
  Printf.printf "%d" (1 + 2);
  [%expect {| 3 |}] (* 运行 dune runtest 后，这里的 3 会自动生成或更新 *)

(* 
    它不会直接变成普通代码，而是注册到一个隐藏的测试框架中, 伪展开代码:

        (* 1. 注册该测试块到全局测试表 *)
        let () =
          Ppx_expect_runtime.Test_block.register_test
            ~config:Ppx_expect_config.default
            ~file:"src/math.ml"
            ~line:1
            ~column:0
            ~description:(Some "addition")
            (fun () ->
               (* 2. 这里的代码被包装成一个闭包 *)
               Printf.printf "%d" (1 + 2);

               (* 3. [%expect] 被转换为一个检查点 *)
               Ppx_expect_runtime.Test_node.check_output
                 ~pos:{ line = 3; col = 2; ... }
                 "3" (* 这是你当前代码里写的期待值 *)
            )
*)

(* ppx_let 用法 *)
(* 简化 Lwt、Async 或 Result 的处理，避免深度嵌套 *)
(* 使用 ppx_let *)
let fetch_data () =
  let%bind user = get_user_id () in     (* 挂起，等待用户 ID *)
  let%bind profile = get_profile user in (* 挂起，等待个人资料 *)
  return (Printf.sprintf "User: %s" profile)


(* 
    展开后:

        let fetch_data () =
          bind (get_user_id ()) (fun user ->
            bind (get_profile user) (fun profile ->
              return (Printf.sprintf "User: %s" profile)))
*)
```


2. **%%** : 表示 模块顶层节点, 独立成行 (用于插入一段定义), 如: 结构/签名项 或 类字段 (级别)


```ml
(* 顶层扩展：生成一段完整的类判断逻辑 *)
[%%js.instanceof: MyClass]        
```


3. **%%%**：表示 签名 (用于声明一些东西), 如: 仅用于 .mli 接口文件或 sig ... end 块中



```ml
(* *.mli 文件 *)

(* 签名扩展：将外部文件的接口声明导入此处 *)
[%%%import: "External_Module.mli"] 


```




*语法糖:*


当扩展点修饰一个具体的定义块（如 `let`, `module`, `val`）时，可以使用缩写：

- `let%html v = ...` 等价于 `[%%html let v = ...]`（顶层）或 `[%html let v = ... in ...]`（局部）

- `val%ext_name foo : unit` 等价于 `[%%%ext_name: val foo : unit]` (mli 中??)

- `match%lwt ...`, `module%js ...` 同理






### @ 






**什么时候用 @？**

当你的代码结构已经是合法的 OCaml，但你想要额外生成辅助工具时。

    例如：`[@@deriving show]`类型定义本身已经很完美了，你只是想让插件“顺便”在下面帮写一个打印函数。





**关于 deriving 与 deriving_inline**

`[@@deriving]` 是隐形的：编译时生成在内存里，你看不到源码，适合保持项目整洁

`[@@deriving_inline]` 是显形的：它会物理上修改你的 .ml 文件，把生成的代码直接写进去


```ml
(* 
如: [@@deriving <deriver_name>] 不会在被归属的物品后面添加生成的代码，而是检查生成的代码是否已经存在于被归属的物品之后. 如果是，那就不必采取任何措施. 否则，它会生成正确的文件.
*)

(* 
此处的归属物为 int, 所以会检查后续的代码是否有 yojson_of_int 和 int_of_yojson 
没有则会生成, 有则不做任何处理
*)
type t = int [@@deriving_inline yojson]
```






1. **@**：修饰 节点级别 (某个 词) ， 如：表达式 或 具体调用点


```ml
(* 只给 a+b 这个加法运算贴标签   编译器内置*)
(* 
    展开后:
        (* 逻辑上等同于：*)
        let sum a b = 
        (* 编译器内部标记：此节点在内联策略中权重极高 *)
        a + b
*)
let sum a b = (a + b) [@inline]  

(* 性能剖析标签，标记这段代码需要计时    库 landmarks 提供 *)
(* 
    展开后:

        let x = 
          (* 1. 进入测量点，记录当前时间/调用栈 *)
          Landmark.enter __landmark_node_1;
          try
            let __result = "hello" in
            (* 2. 正常结束，记录时间差 *)
            Landmark.exit __landmark_node_1;
            __result
          with e ->
            (* 3. 异常结束，也要闭合计时点并重新抛出异常 *)
            Landmark.exit __landmark_node_1;
            raise e
*)
let x = "hello" [@landmark]       
```

2. **@@**：修饰整个定义，如：定义块（type, let, module, val）的末尾


```ml

(* 给整个 user 类型贴标 *)
(* 
    展开后:     (在内存中展开， 不会修改源代码, 等效于下面的代码)

        type user = { id : int }

        (* 由 ppx_deriving_show 自动插入, 生成一个格式化函数 pp_user  *)
        let pp_user fmt { id } = 
          Format.fprintf fmt "{ id = %d }" id

        (* 由 ppx_deriving_show 自动插入, 生成一个转字符串函数 show_user  *)
        let show_user x = 
          Format.asprintf "%a" pp_user x

*)
type user = { id : int } [@@deriving show] 


(* deriving_inline 的特殊性：*)
(* 
    展开后:     (它是生成代码到源码中，方便查阅，而不是在内存中生成)

        type t = int [@@deriving_inline yojson]

        (* --- 以下是自动插入的代码，受 [@@@end] 保护 --- *)
        let t_of_yojson (json : Yojson.Safe.t) : t = 
          match json with
          | `Int i -> i
          | _ -> Ppx_yojson_conv_lib.Yojson_conv_error.expected "int" json

        let yojson_of_t (x : t) : Yojson.Safe.t = `Int x
        (* --- 自动插入结束 --- *)

        [@@@end]
*)
type t = int [@@deriving_inline yojson]
(* ... 这里是生成的代码 ... *)
[@@@end] 
(*  *)

```



3. **@@@**：修饰整个块 或者 整个环境 (浮动属性), 独立成行 

```ml

(* 告诉编译器：这个文件里所有未使用的变量都不要报错 *)
(* 
    无代码展开,  
*)
[@@@warning "-32"] 

(* 
又如:
*)
(* 忽略整个文件里“未使用的变量”警告 *)
[@@@warning "-27"]
let x = 10 (* 即便 x 没被用到，也不会警告 *)

(* 
又如:
*)
(* [@@@]: 全局开启调试日志      JaneStreet 提供 *)
(* 在此文件内，所有的 [%log.debug ...] 都会被展开为真实的打印逻辑 *)
[@@@ppx_config log_level_debug]

let test_function x =
  [%log.debug "Current value of x: %d" x]; (* 此时这行代码有效 *)
  x + 1 
```
