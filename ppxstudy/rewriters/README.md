<!-- 经 Codex 整理，更新日期：2026-09-08。 -->

# rewriters 源码导读

本目录是早期 ppxlib 实验代码，不是已发布的 PPX 套件。以下说明按每个 `.ml` 实际注册的 `Extension.Context` 和构造的 AST 编写；“语义等价”省略位置、卫生名字及版本相关细节。

## 先看语法与 Context

`%`/`%%` 和 `@`/`@@`/`@@@` 不是从“小节点到大节点”的六级系统。前两组分别属于扩展节点与属性：

- expression 扩展常写 `[%debug e]`。
- structure-item 扩展常写 `[%%auto ...]`。
- pattern、core type、module expression 等 Context 也使用扩展节点；不能把它们改称 `@`、`@@`、`@@@` 扩展。
- `[@attr]`、`[@@attr]`、`[@@@attr]` 是三种属性附着形式。本目录所有实现均调用 `Extension.declare`，没有一个使用 `Attribute.declare`。
- 没有标准 `[%%%...]`。“whole-file transformation”是 Driver API 的处理范围，不是第三种百分号语法。

## 表达式扩展

### `ppx_debug.ml`

**用法**：`let x = [%debug 1 + 2]`。

**展开后（语义等价）**：先打印 `"1 + 2"`，再执行 `let result = 1 + 2`，尝试打印 result，最后返回 result。

**意义与限制**：展示 `single_expr_payload` 和 metaquot。源码用 `Obj.magic` 把任意结果交给 `Printexc.to_string`，既不是通用 pretty-printer，也不安全；生产代码应接收显式打印函数或只记录源码和位置。

### `ppx_calc.ml`

**用法**：`let x = [%calc (2 * 7)]`。

**展开后（按真实源码）**：整数常量原样返回；顶层为 `+`、`-`、`*`、`/` 的二元调用一律变成 `42`；其他表达式原样返回。因此例子得到 `let x = 42`，不是计算出的 `14`。

**意义与限制**：这是 AST 匹配骨架和“占位实现”反例，不是常量求值器。若继续实现，必须递归求值、处理除零/溢出、拒绝变量及副作用，并写展开测试。

### `ppx_log.ml`

**用法**：`let x = [%log f ()]`。

**展开后（语义等价）**：打印由 `__FILE__`、`__LINE__` 组成的位置，求值 `f ()`，以 `Obj.magic` 尝试打印结果，再返回结果。

**意义与限制**：展示在表达式求值前后插入代码；结果打印与 `ppx_debug` 一样不安全，日志位置也是生成代码中的编译器内置标识，不是直接使用 expander 的 `loc` 固化出的值。

## 结构项扩展

### `ppx_auto.ml`

**用法（注册意图）**：`[%%auto type color = Red | Green | Blue]`；不是旧说明中的 `[%%auto let greet ...]` 自动补 `greet_all`。

**展开后（源码意图）**：遍历 payload；类型项试图生成 `to_string`/`of_string` 或 `get_<field>`，再保留原类型，非类型项只原样返回。

**意义与限制**：展示 structure-item payload 遍历，但当前实现不可用：普通 variant 被误建成 polymorphic variant pattern，未知分支引用未绑定 `_s`，辅助定义还放在类型定义之前，多类型也会产生命名冲突。它需要重构和测试后才能启用。

### `ppx_module_wrapper.ml`

**用法（与 Context 一致）**：

```ocaml
[%%module_wrapper
  let x = 42
  let add a b = a + b]
```

**展开后（语义等价）**：

```ocaml
module WrappedModule = struct
  let x = 42
  let add a b = a + b
end
open WrappedModule
```

**意义与限制**：展示一个结构项扩展返回多个结构项。它不处理“整个文件”，不支持 `.mli`，模块名固定，多个使用点会冲突。旧写法 `[%%%module_wrapper ...]` 不是标准 OCaml。

## 模式 Context 实验

以下五个文件共同存在一个结构性问题：它们声明 `Extension.Context.pattern`，却用 `Ast_helper.Pat.when_` 试图返回 `pattern when expression`。guard 属于 `case`（`pc_guard`），不是 `pattern`；当前 ppxlib API 下这些实现不能构建。正确方向是改写整个 match/function case，或让模式扩展只返回合法模式。

### `ppx_regex.ml`

**用法（意图）**：匹配字符串是否满足正则表达式。

**展开后（意图示意）**：`| value when Str.string_match (Str.regexp pattern) value 0 -> ...`。

**意义与限制**：目标是把 DSL 变成 guard；旧 `_ @regex "..."` 不是此 `Extension.declare` 对应的标准扩展写法。正则还在每次匹配时编译，并捕获所有异常。

### `ppx_range.ml`

**用法（意图）**：范围上下界作为 payload。

**展开后（意图示意）**：`| value when value >= min && value <= max -> ...`。

**意义与限制**：目标是生成范围 guard；源码的 `pair __ __` 约束、旧 `_ @range 90 100` 写法及返回节点类型需要重新设计。上下界是闭区间，旧示例 `90..100` 与 `80..90` 会在 90 重叠。

### `ppx_is_type.ml`

**用法（意图）**：`is_int`、`is_string`、`is_float`、`is_bool`、`is_list` 五个无 payload 模式判断。

**展开后（意图示意）**：对匹配值调用 `Obj.repr`/`Obj.tag` 后比较标签。

**意义与限制**：除 guard 构造无效外，这也不是可靠的 OCaml 运行时类型检查：不同静态类型会共享运行时表示，变体、列表、字符串等不能靠这里的标签安全区分。应优先用普通代数数据类型模式匹配。

### `ppx_valid.ml`

**用法（意图）**：把布尔表达式变成 case guard。

**展开后（意图示意）**：`| original_pattern when condition -> ...`。

**意义与限制**：当前实现没有接收或保留 `original_pattern`，只生成 `_valid_match`，所以条件若引用 `name`、`age` 等原模式绑定会未绑定。应在 case 层处理模式与 guard。

### `ppx_formats.ml`

**用法（意图）**：`json`、`xml`、`yaml` 三个无 payload 模式判断。

**展开后（意图示意）**：`| value when detect_json value -> ...` 等。

**意义与限制**：除了 guard 问题，`detect_json/xml/yaml` 只定义在 PPX 进程源码里，却被生成代码以未限定名字调用，使用方不会自动得到这些运行时函数。检测逻辑也只是首尾字符启发式，不是解析器。

## 类型表达式扩展

### `ppx_alias.ml`

**用法（与注册 Context 一致）**：概念上会是 `type t = [%alias "AliasName"]`，而不是 `type t @@ alias ...`。

**展开后（按真实源码）**：字符串 payload 会在 PPX 进程打印一行后直接 `failwith`；其他 payload 也 `failwith`，没有任何成功展开。

**意义与限制**：仅是 `Extension.Context.type_expr` 的未完成骨架。若目标是给类型声明添加元数据，更自然的设计通常是 `[@@alias "AliasName"]` 配合 `Attribute.declare`，或一个 deriver。

## 模块表达式扩展

这四个文件注册的是 `Extension.Context.module_expr`。该 Context 的扩展节点会占据模块表达式位置，例如最小形态 `module M = [%wrapped]`。旧文中的 `module M @@@ wrapped = ...` 和 `[@@@wrapped module M = ...]` 都不是这些注册规则的用法。更关键的是，`Extension.declare` 的 `Ast_pattern` 匹配 extension payload；当前四个文件用 `Ast_pattern.__` 捕获 payload 后却把它当成 `module_expr` 读取 `pmod_desc`，实现本身存在类型/设计错误，所以下面的“用法”都是目标 API 草图而非当前可运行语法。

### `ppx_wrapped.ml`

**用法（设计意图）**：用扩展包装一个 `struct ... end` 模块表达式；实现时应先为 payload 规定可解析编码，或改用适合 `module%wrapped ...` 的 structure-item 规则。

**展开后（语义等价）**：对 `struct ... end` 在最前面插入 `let __wrapped_module = "wrapped"`；非 structure 模块表达式原样返回。

**意义与限制**：最小的 module-expression 改写示例。固定标识符可能与用户代码冲突，生产实现应生成卫生名字或明确定义公共接口。

### `ppx_timed.ml`

**用法（设计意图）**：包装一个包含 `let f x = body` 的结构模块。

**展开后（源码意图）**：在每个简单变量值绑定的最外层 `fun` 函数体周围调用 `Unix.gettimeofday`，打印成功或异常耗时。

**意义与限制**：只拆一层 curried function，所以 `let f x y = ...` 实际只计量“给定 x 后创建闭包”；它把递归绑定重建为 `Nonrecursive`，会破坏递归和互递归。生成代码还要求使用方链接 `unix`。

### `ppx_logged.ml`

**用法（设计意图）**：包装一个包含 `let f x = body` 的结构模块。

**展开后（源码意图）**：在最外层函数体前打印 called，成功后打印 returned，异常时打印 raised；非函数表达式在初始化时打印 executed。

**意义与限制**：同样只处理一层参数，并丢失 `rec_flag`、值绑定属性和复杂模式语义；递归函数会被破坏。

### `ppx_cached.ml`

**用法（设计意图）**：包装一个包含 `let f x = body` 的结构模块。

**展开后（源码意图）**：为简单值绑定增加 `f_cache = Hashtbl.create 16`，查询失败后计算并写入。

**意义与限制**：当前代码把 pattern 当 expression 反引用来构造 key，无法正确编译；同时丢失递归性，只处理一层参数，并假定任意输入可安全哈希、函数纯且结果可永久缓存。旧 README 展示的按 `x` 缓存不是当前 AST 的可靠结果。

## 构建与验证

基础依赖：

```sh
opam install dune ppxlib
eval "$(opam env)"
dune build ppxstudy/rewriters/ppx_study_rewriters.cma
```

当前快照预计会在上述模式 guard 等实验代码处失败；这正是本页标注限制的原因。修复一个 rewriter 后，使用方还应显式启用并链接生成代码所需运行时库：

```lisp
(executable
 (name demo)
 (libraries str unix)
 (preprocess (pps ppx_study_rewriters)))
```

生产化顺序建议：先单独保留一个最小扩展，使用 `Extension.V3.declare`、`Ast_builder` 和唯一命名空间；再添加展开快照、错误位置、求值次数/顺序、异常路径和组合顺序测试。完整骨架见[自定义实现知识库](../docs/PPX-自定义实现-由Codex生成.md)。
