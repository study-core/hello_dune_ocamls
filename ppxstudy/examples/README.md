<!-- 经 Codex 整理，更新日期：2026-09-08。 -->

# examples 示例说明

本目录同时保存了真实生态 PPX 用法、普通 OCaml 的语义模拟，以及早期的概念草稿。下文以源码和 `examples/dune` 为准，不把“看起来像 PPX”的文本都称作可运行扩展。

## 逐文件对照

### `basic_attributes.ml`

**用法**：运行 `dune exec ./ppxstudy/examples/basic_attributes.exe`；文件使用浮动属性 `[@@@warning "-32-34"]`、关键字属性 `let[@inline]` 和声明属性 `[@@deprecated ...]`。

**展开后（语义等价）**：普通 OCaml 源码仍是 `sum_to`、`old_number` 和入口表达式；这些属性不生成一组可见的替代定义。编译器读取它们来控制告警、优化提示和弃用信息。

**意义与状态**：这是本目录的无第三方依赖起点，可直接构建运行。它也说明 `@` 不只用于模式，且“属性生效”不等于“生成源码”。

### `run_examples.ml`

**用法**：汇总 `[%show: person]`、`[%eq: person]`、`[%here]`、`[%env ...]`、`[%%test ...]`、条件编译和普通模块。

**展开后（语义等价）**：`[%show: person] alice` 调用 deriver 生成的 `show_person alice`；`[%eq: person] a b` 调用 `equal_person a b`；`[%here]` 生成源码位置值；测试和条件编译由相应 PPX 注册或选择代码。`classify_string` 与 `Logger` 本来就是普通 OCaml，没有 PPX 展开。

**意义与状态**：适合辨认多种形状，但当前 Dune stanza 只有 `(libraries core str)`，没有 `(preprocess (pps ...))`，因此不是当前可执行目标。`[%env]` 和 `[%%ifdef]` 也必须以所选 provider 的实际语法为准。

### `percent_examples.ml`

**用法**：表达式扩展 `[%show: person]`、`[%eq: point]`、`[%here]`、`[%env ...]`，以及本项目的 `[%debug ...]`、`[%calc ...]`。

**展开后（语义等价）**：前两者分别成为 `show_person alice` 和 `equal_point p1 p2`；`[%here]` 生成位置记录或运行时位置值，具体类型由 provider 决定。按当前源码，`[%calc 2 * (3 + 4)]` 不是 `14`，而是占位常量 `42`；`[%debug e]` 先打印源码，再求值 `e`，最后以不安全的 `Obj.magic` 尝试打印结果。

**意义与状态**：展示 expression Context。当前 Dune 未启用任何上述 PPX，`ppx_calc` 也只是反例实现，不应宣称编译期求值正确。

### `double_percent_examples.ml`

**用法**：包含 `[%%test ...]`、`[%%ifdef ...]`、`[%%bench ...]` 和 `[%%auto ...]`。

**展开后（语义等价）**：inline test 通常生成测试注册代码，而不是“构建时直接执行”；条件编译保留一个分支；benchmark 通常注册基准任务，而不是自动拿未定义的 `expected_time` 比较。当前 `ppx_auto` 对非类型结构项只原样返回，所以 `[%%auto let greet ...]` 只得到原来的 `let greet`，不会生成 `greet_all`。

**意义与状态**：展示 structure-item Context，但四种名字来自不同 provider 或本项目实验代码。当前 Dune 未声明这些 `pps`，`bench` 也不由 `ppx_inline_test` 提供。

### `at_examples.ml`

**用法**：源码写了 `_ @regex ...`、`_ @range ...`、`_ @is_int`、`pat @valid ...` 等教学记号。

**展开后（意图示意）**：README 旧版把它们写成 `pat when condition`。这只是目标语义，不是当前重写器的有效输出。

**意义与状态**：`@` 在 OCaml 模式中本来就是 alias-pattern 语法的一部分，而属性应写成 `(pat [@name ...])`，模式扩展节点则使用该位置允许的 `[%name ...]` 形式。当前 `ppx_regex/range/is_type/valid/formats` 声明的是 `Extension.Context.pattern`，却试图返回 guard；guard 属于 match case，不属于 pattern，且 ppxlib 没有可这样使用的 `Ast_helper.Pat.when_`。因此这些文件是设计反例，不能构建。旧文提到的 `ppx_pattern_bind`/`@bind` 也未在本仓库声明或验证，已不作为依赖建议。

### `double_at_examples.ml`

**用法**：`[@@deriving show]`、`eq`、`yojson`、`sexp`，并使用对应表达式扩展。

**展开后（语义等价）**：deriver 保留类型声明并在其后生成 `pp_*`/`show_*`、`equal_*`、`yojson_of_*`/`*_of_yojson`、`sexp_of_*`/`*_of_sexp` 等函数。生成函数名、错误处理、字段顺序和运行时模块路径以实际版本的 `-dsource` 输出为准；旧 README 中的 `Fmt.pf`、只接受固定字段顺序的 JSON 模式不是可靠逐字展开。

**意义与状态**：`[@@deriving ...]` 在语法上是附着到类型声明的属性，由 deriver 消费。当前 Dune 只链接 `core`，没有启用 providers，不能构建。

### `triple_at_examples.ml`

**用法**：包含 `[@@@warning ...]` 等浮动属性、自定义 `[@@@wrapped module ...]` 草稿，以及手写的 `Manual*` 模块。

**展开后（语义等价）**：`[@@@warning "-9"]` 不生成普通源码，而是改变随后范围的告警设置。`[@@@inline]`、`[@@@tailcall]` 等并不因为写成浮动属性就自动作用于随后所有函数；每个编译器属性只在手册规定的 AST 节点上有意义。`[@@@wrapped ...]` 是浮动属性加 structure payload，不会调用声明为 `module_expr` 扩展的 `ppx_wrapped`。文件后半的 `Manual*` 是手写语义模拟，不是展开产物。

**意义与状态**：用于比较浮动属性和普通代码。源码还含重复模块名、未提供的外部 primitive 等实验内容，不应作为可运行目标。

### `triple_percent_examples.ml` / `.mli`

**用法**：旧草稿使用 `[%%%module_wrapper ...]` 和 `[%%%auto_include ...]`。

**展开后（教学意图）**：草稿希望把一段结构包装为 `module WrappedModule = struct ... end` 再 `open WrappedModule`。

**意义与状态**：`%%%` 不是 OCaml 手册规定的第三种扩展语法，标准解析器会拒绝这些文件。当前 `ppx_module_wrapper.ml` 实际注册 `Extension.Context.structure_item`，只支持实现文件中的 `[%%module_wrapper ...]`，不支持 `.mli` 签名，也不实现 `auto_include`。后面的 `ManualWrappedModule` 只是普通 OCaml 对照。

## 依赖与 Dune 配置

本目录当前的 `dune` 只声明运行时库，未启用源码所用 PPX。安装包后，还必须在每个目标上添加相应 `preprocess`：

| 源码能力 | opam 包 | 常见 Dune `pps` 名称 |
|---|---|---|
| `show`、`eq` deriver/扩展 | `ppx_deriving` | `ppx_deriving.show`、`ppx_deriving.eq` |
| `[%here]` | `ppx_here` | `ppx_here` |
| `[@@deriving yojson]` | `ppx_deriving_yojson` | `ppx_deriving_yojson` |
| `[%yojson_of: t]`（Jane Street 风格） | `ppx_yojson_conv` | `ppx_yojson_conv` |
| `[@@deriving sexp]` / `[%sexp_of: t]` | `ppx_sexp_conv` | `ppx_sexp_conv` |
| `let%test` / inline tests | `ppx_inline_test` | provider 文档规定的 rewriter，常由 `ppx_jane` 组合启用 |
| expect tests | `ppx_expect` | `ppx_expect` |
| 条件编译 | `ppx_optcomp` | `ppx_optcomp` |

例如只运行 `show`、`eq`、`here` 的目标可写：

```lisp
(executable
 (name demo)
 (libraries core)
 (preprocess
  (pps ppx_deriving.show ppx_deriving.eq ppx_here)))
```

`(libraries core)` 只负责链接 `Core`，不会自动启用 PPX。`[%env]`、`[%%test]`、`[%%bench]` 的具体拼写在生态中并不统一；选择 provider 后应照其文档修改源码和 `pps`，不能仅安装一个“官方 PPX”包。OCaml 编译器本身不提供这些扩展。

## 查看展开与排错

```sh
dune describe pp ppxstudy/examples/double_at_examples.ml
dune build --verbose
```

若出现 `Uninterpreted extension`，先检查扩展名、AST Context 和 `(preprocess (pps ...))`。未知属性可能被忽略，所以“没有报错”并不能证明某个 `[@...]` 生效。
