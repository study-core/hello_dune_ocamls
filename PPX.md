# PPX 用法

PPX 的机制，允许您通过 -ppx 编译器标志添加到编译管道代码，以在语法级别转换 OCaml 程序。

OCaml 中有两种主要形式的扩展点：

- 属性          [@、@@、@@@]
- 扩展节点      [%、%%、%%%]


### 属性

属性 提供附加到 OCaml 语法树中的节点的附加信息，并随后由外部工具解释和扩展。


属性的基本形式是 `[@ ... ]` 语法。 `@` 符号的数量定义了属性绑定到语法树的哪一部分：

- 单个 [@ 使用后缀表示法绑定到 [代数] 类别，例如：[类型定义中的表达式]  或  [单个构造函数]。

- 双 [@@ 绑定到 [代码块]，例如：[模块定义、类型声明或类字段]。

- 三重 [@@@ 在模块实现或签名中显示为 [独立条目]，并且 [不绑定到任何特定的源代码节点]。



**注：** OCaml 编译器有一些有用的内置属性，我们可以使用它们来说明它们的用法，而无需任何外部工具。



**一重 @**  [类型定义中的表达式]  或  [单个构造函数]



附加到单个 [表达式上] 。在下一个示例中， @warn_on_literal_pattern 属性指示 类型构造函数的 参数 不应与常量文字进行模式匹配。

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



让我们首先看看如何使用独立属性 @@@warning 来切换 OCaml 编译器警告。

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


属性 提供附加到 OCaml 语法树中的节点的附加信息，并随后由外部工具解释和扩展。


属性的基本形式是 `[@ ... ]` 语法。 `@` 符号的数量定义了 属性绑定 到语法树的哪一部分：

- 单个 [@ 使用后缀表示法绑定到 [代数] 类别，例如：[类型定义中的表达式]  或  [单个构造函数]。

- 双 [@@ 绑定到 [代码块]，例如：[模块定义、类型声明或类字段]。

- 三重 [@@@ 在模块实现或签名中显示为 [独立条目]，并且 [不绑定到任何特定的源代码节点]。



**注：** OCaml 编译器有一些有用的内置属性，我们可以使用它们来说明它们的用法，而无需任何外部工具。



**一重 @**  [类型定义中的表达式]  或  [单个构造函数]


扩展点 对于 `注释` 现有源代码很有用。还可以在 OCaml AST 中存储通用 `占位符` 以进行代码生成。 


扩展节点的一般语法是 `[%id expr]` ，其中 `id` 是特定 扩展节点重写器 的 标识符， `expr` 是 重写器 要解析的有效负载。当有效负载具有相同类型的语法时，中缀形式也是可用的。例如 let%foo bar = 1 相当于 [%foo let bar = 1] 。