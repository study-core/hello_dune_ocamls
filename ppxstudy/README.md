# PPX Study - PPX 扩展学习项目

这个项目演示了 OCaml 中各种 PPX 扩展的用法，包括官方扩展和自定义扩展。

## 项目结构

```
ppxstudy/
├── examples/          # ppx 示例
│   ├── README.md            # 示例详细说明和运行指南
│   ├── run_examples.ml      # 综合演示
│   ├── percent_examples.ml  # % 扩展节点示例
│   ├── double_percent_examples.ml  # %% 扩展节点示例
│   ├── triple_percent_examples.ml  # %%% 扩展节点示例
│   ├── triple_percent_examples.mli # %%% 扩展节点说明
│   ├── at_examples.ml       # @ 属性节点示例
│   ├── double_at_examples.ml  # @@ 属性节点示例
│   └── triple_at_examples.ml  # @@@ 属性节点示例
├── rewriters/         # 自定义 PPX 重写器
│   ├── README.md             # 重写器详细说明
│   ├── ppx_debug.ml          # %debug 扩展
│   ├── ppx_auto.ml           # %%auto 扩展
│   ├── ppx_module_wrapper.ml # %%%module_wrapper 扩展
│   ├── ppx_regex.ml          # @regex 扩展
│   ├── ppx_alias.ml          # @@alias 扩展
│   ├── ppx_wrapped.ml        # @@@wrapped 扩展
│   ├── ppx_calc.ml           # %calc 扩展
│   └── ppx_log.ml            # %log 扩展
├── dune              # 构建配置
└── README.md         # 本文件
```

## PPX 扩展类型说明

### % (表达式扩展点)
- **位置**：表达式中
- **示例**：`[%show: person] p`, `[%eq: person] a b`
- **用途**：数据序列化、比较、调试

### %% (结构项扩展点)
- **位置**：顶层声明间
- **示例**：`[%%test "name"]`, `[%%bench "name"]`
- **用途**：测试、基准测试、条件编译

### %%% (文件扩展点)
- **位置**：整个文件
- **示例**：`[%%%module_wrapper file_content]`
- **用途**：文件级别的代码转换

### @ (模式扩展点)
- **位置**：模式匹配中
- **示例**：正则表达式匹配、范围匹配
- **用途**：增强模式匹配能力

### @@ (类型扩展点)
- **位置**：类型定义中
- **示例**：`[@@deriving show]`
- **用途**：类型派生、验证

### @@@ (模块扩展点)
- **位置**：模块定义中
- **示例**：模块计时、日志包装
- **用途**：模块变换、AOP

## 安装依赖

```bash
# 官方 PPX 扩展
opam install ppx_deriving ppx_inline_test ppx_expect

# 第三方扩展
opam install ppx_yojson_conv ppx_sexp_conv ppx_here ppx_env

# 构建工具
opam install dune
```

## 运行示例

```bash
# 构建项目
dune build

# 查看 examples/README.md 获取详细的运行指南
# 包含所有示例的运行方法和说明

# 快速开始：运行综合示例
dune exec ./ppxstudy/examples/run_examples.exe
```

## 学习资源

- [PPX 官方文档](https://ocaml.org/docs/metaprogramming)
- [ppxlib 文档](https://github.com/ocaml-ppx/ppxlib)
- [ppx_deriving](https://github.com/ocaml-ppx/ppx_deriving)
