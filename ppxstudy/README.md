<!-- 经 Codex 整理，更新日期：2026-09-08。 -->

# PPX 学习区

本目录用于学习 OCaml PPX 的语法、展开结果和自定义实现。阅读时先记住：PPX 操作解析后的 `Parsetree`，发生在类型检查之前；它不是文本宏，也看不到 `Typedtree` 中的推断类型。

## 先分清扩展节点和属性

| 类别 | 常见写法 | 含义 | 没有消费者时 |
|---|---|---|---|
| 扩展节点 | `[%name ...]`、`[%%name ...]`、`let%name` | AST 中等待替换的节点 | 通常报 `Uninterpreted extension` |
| 属性 | `[@name]`、`[@@name]`、`[@@@name]` | 附着在已有节点上的元数据 | 编译器或工具可以使用，也可以忽略 |

这些符号不是六个互斥“级别”：

- `[%...]` 可出现在表达式、模式、核心类型、模块表达式等多种 AST 上下文；`[%%...]` 通常是完整的结构项或签名项扩展。`let%foo`、`module%foo` 等是关键字后缀形式。
- `[@...]` 是附着到局部节点的属性，不只用于模式；`[@@...]` 通常附着到包含它的声明；`[@@@...]` 是独立的浮动属性结构项或签名项。
- OCaml 手册没有把 `[%%%...]` 定义为“第三种/文件级扩展”。本项目旧示例中的 `[%%%module_wrapper ...]` 是教学时期的自定义记号，标准解析器并不接受。真实的 `ppx_module_wrapper.ml` 声明的是 `structure_item` 上下文，应写成 `[%%module_wrapper ...]`。
- `Format.printf "@[<hov 2>%a@]" pp value` 中的 `@[` 和 `%a` 位于普通格式字符串内，与 PPX 无关。

## 目录

```text
ppxstudy/
├── README.md
├── docs/
│   ├── INDEX.md
│   ├── PPX-展开对照-由Codex生成.md
│   └── PPX-自定义实现-由Codex生成.md
├── examples/
│   ├── README.md
│   └── *.ml / *.mli
└── rewriters/
    ├── README.md
    └── ppx_*.ml
```

- [知识库索引](docs/INDEX.md)：主题和本项目文件的对应关系。
- [PPX 展开对照](docs/PPX-展开对照-由Codex生成.md)：语法、官方/生态 PPX 和语义等价展开。
- [PPX 自定义实现](docs/PPX-自定义实现-由Codex生成.md)：用 ppxlib 声明、注册、测试扩展和属性。
- [示例说明](examples/README.md)：逐文件说明用途、展开和当前可运行状态。
- [重写器说明](rewriters/README.md)：逐实现核对真实 Context、输出和限制。

## 建议学习路径

1. 先读[展开对照](docs/PPX-展开对照-由Codex生成.md)，建立“语法位置决定 Context”的模型。
2. 运行 `dune exec ./ppxstudy/examples/basic_attributes.exe`，再按 [examples/README.md](examples/README.md) 选择需要额外依赖的示例，并用 `dune describe pp FILE` 查看预处理结果。
3. 再读[自定义实现](docs/PPX-自定义实现-由Codex生成.md)，完成其中独立的小工程。
4. 最后对照 [rewriters/README.md](rewriters/README.md) 和 `rewriters/*.ml`。这些文件是早期实验代码，其中一些保留为反例，不能等同于生产实现。

## 依赖和运行

基础工具：

```sh
opam install dune ppxlib
eval "$(opam env)"
```

知识库中的独立自定义 PPX 教程只需要 `dune` 和 `ppxlib`。本仓库旧 examples 还引用多个生态包；按需安装，不要把所有语法误认为 OCaml 内置：

```sh
opam install core ppx_deriving ppx_inline_test ppx_expect \
  ppx_here ppx_optcomp ppx_yojson_conv ppx_sexp_conv
```

启用 PPX 必须在使用方的 Dune stanza 中声明，例如：

```lisp
(preprocess
 (pps ppx_deriving.show ppx_deriving.eq ppx_here))
```

`[@@deriving yojson]` 与 `[%yojson_of: t]`、`[@@deriving sexp]` 还需要各自 provider，准确库名和组合见 [examples/README.md](examples/README.md)。仅把运行时库写进 `(libraries ...)` 不会启用 PPX。

常用命令：

```sh
dune build
dune exec ./ppxstudy/examples/basic_attributes.exe
dune describe pp ppxstudy/examples/basic_attributes.ml
```

当前快照的 examples/rewriters 尚不是全绿示例集：Dune 声明缺少若干 `pps`，一些文件还保留了非标准教学语法。先看两份目录 README 中的状态说明；遇到未解释扩展时，不应把它当成普通函数缺失。

## 参考

- [OCaml 手册：Extension nodes](https://ocaml.org/manual/extensionnodes.html)
- [OCaml 手册：Attributes](https://ocaml.org/manual/attributes.html)
- [ppxlib 文档](https://ocaml-ppx.github.io/ppxlib/)
