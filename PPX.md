# PPX 用法

PPX 的机制，允许您通过 -ppx 编译器标志添加到编译管道代码，以在语法级别转换 OCaml 程序。

OCaml 中有两种主要形式的扩展点：

- 属性          [@、@@、@@@]
- 扩展节点      [%、%%、%%%]


### 属性

[属性] 的语法是为节点添加后缀 `[@attribute_name    payload]` ，其中 `payload` 本身就是 OCaml AST


[属性] 提供附加到 OCaml 语法树中的节点的附加信息，并随后由外部工具解释和扩展。


[属性] 的基本形式是 `[@ ... ]` 语法。 `@` 符号的数量定义了 [属性] 绑定到语法树的哪一部分：

- 单个 [@ 使用后缀表示法绑定到 [代数] 类别，例如：[类型定义中的表达式]  或  [单个构造函数] 或 [模式]。

- 两个 [@@ 绑定到 [代码块]，例如：[模块定义、类型声明、类字段]。

- 三重 [@@@ 在模块实现或签名中显示为 [独立条目]，并且 [不绑定到任何特定的源代码节点]。



**注：** OCaml 编译器有一些有用的内置 [属性]，我们可以使用它们来说明它们的用法，而无需任何外部工具。



**一重 @**  [类型定义中的表达式]  或  [单个构造函数]



附加到单个 [表达式上] 。在下一个示例中， @warn_on_literal_pattern  [属性] 指示 类型构造函数的 参数 不应与常量文字进行模式匹配。

```ml
type program_result =

| Error of string [@warn_on_literal_pattern]  (* 附加到 表达式 *)
| Exit_code of int;;

let exit_with = function
| Error "It blew up" -> 1   (* Error "It blew up" 就会报错， 应入参为  字符串变量 *)
| Exit_code code -> code
| Error _ -> 100;;


(* 
所以当用到 构造子 Error 且入参为 字符串字面量 时，报：

    Line 2, characters 11-23:
    Warning 52 [fragile-literal-pattern]: Code should not depend on the actual values of
    this constructor's arguments. They are only for information
    and may change in future versions. (See manual section 11.5)
    val exit_with : program_result -> int = <fun>
*)

```


**双重 @@**   [代码块]



注释也可以更狭窄地附加到 [代码块]。例如，模块实现可以用 @@deprecated 进行注释，以指示它不应在新代码中使用：

```ml

module Planets = struct
  let earth = true
  let pluto = true
end [@@deprecated "Sorry, Pluto is no longer a planet. Use the Planets2016 module instead."];;

module Planets2016 = struct
  let earth = true
  let pluto = false
end;;


(* 
如果开发人员使用了  Planets 的东西，则就会报: 
    Line 1, characters 25-38:
    Alert deprecated: module Planets
    Sorry, Pluto is no longer a planet. Use the Planets2016 module instead.
*)
```




**三重 @@@**      [独立条目,不绑定任何源代码节点]



让我们首先看看如何使用独立 [属性] `@@@warning` 来切换 OCaml 编译器警告。

```ml
module Abc = struct

[@@@warning "+non-unit-statement"] (* 用在当前条目 *)
let a = Sys.get_argv (); ()

[@@@warning "-non-unit-statement"]
let b = Sys.get_argv (); ()
end;;

(* 如果序列中的表达式不具有类型 unit ，此警告将发出一条消息。 *)

```


**在 dune 文件中的定义**

```

(library
 (name hello_world)
 (libraries core)
 (preprocess (pps ppx_jane))
```


### 拓展点


[扩展节点] 的语法是 `[%extension_name     payload]` 

其中 % 的数量决定了 [扩展节点] 的类型： 


- 单个 [% 表示 "内部节点", 例如: [表达式] 和 [模式]
- 两个 [%% 表示 "顶层 (toplevel) 节点", 例如: [结构] 或 [签名项] 或 [类字段]
  
`payload` 是一个 [结构节点]; 也就是说，解析器接受 `.ml 文件` 的相同内容作为 [扩展节点] 的有效 `payload` 。


[扩展节点] 对于 `注释` 现有源代码很有用。还可以在 OCaml AST 中存储通用 `占位符` 以进行代码生成。 


[扩展节点] 的一般语法是 `[%id expr]` ，其中 `id` 是特定 `扩展节点重写器` 的 标识符， `expr` 是 `重写器 要解析的有效 payload 信息`。当 `有效 payload` 具有相同类型的语法时，中缀形式也是可用的。例如: `let%foo bar = 1 相当于 [%foo let bar = 1]` 。


```ml
(* An extension node as an expression                         作为 表达式 的扩展节点 *)
let v = [%html "<a href='ocaml.org'>OCaml!</a>"]

(* An extension node as a let-binding                         作为 let 绑定 的扩展节点 *)
[%%html let v = "<a href='ocaml.org'>OCaml!</a>"]

```

当 [扩展节点] 和 `有效 payload` 具有相同类型时，可以使用更短的中缀语法。该语法要求将 [扩展节点] 的名称附加到定义块的关键字 (例如: let 、 begin 、 module、 val 等)，并且相当于将整个块 包 装在 `有效 payload`


```ml
(* An equivalent syntax for [%%html let v = ...]              [%%html let v = ...] 的等价语法 *)
let%html v = "<a href='ocaml.org'>OCaml!</a>"
```


**注意:** 有一种方法可以 更改 `有效 payload` 的预期类型。

  通过在扩展名后面添加 `:` , 预期的 `有效 payload` 现在是一个 [签名节点] (即与 .mli 文件中接受的内容相同)。 类似地  `?`  会将预期的 `有效 payload` 转换为 [模式节点]。


 ```ml
 (* Two equivalent syntaxes, with signatures as payload       以签名作为 [有效payload] 的两种等效语法 *)
[%ext_name: val foo : unit]

val%ext_name foo : unit


(* An extension node with a pattern as payload                以模式为 [有效payload] 的扩展节点 *)
let [%ext_name? a :: _ ] = ()
 ```


扩展节点旨在由 PPX 重写，在这方面，对应于一种特定类型的 PPX `扩展器`。 
扩展器是 PPX 重写器，它将用匹配的名称替换所有出现的 [扩展节点]。
它使用一些仅依赖于 `有效 payload` 的生成代码来执行此操作，没有有关 [扩展节点] 上下文的信息 (即: 无法访问代码的其余部分)，也无需修改任何其他内容。