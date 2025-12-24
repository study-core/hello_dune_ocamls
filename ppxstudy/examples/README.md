# PPX 扩展示例

这个目录包含了各种 PPX 扩展的实际使用示例，每个文件演示不同类型扩展的具体用法。

## 示例文件说明

### run_examples.ml - 综合示例
展示所有主要 PPX 扩展类型的实际使用：
- `%` 扩展：`[%show: person]`, `[%eq: point]`, `[%here]`, `[%env "PORT"]`
- `%%` 扩展：`[%%test "..."]`, `[%%ifdef DEBUG]`, `[%%bench "..."]`
- `@@` 扩展：`[@@deriving show, eq, yojson]`
- 模块定义和使用

### percent_examples.ml - % 扩展示例
专门演示表达式级别的扩展：
```ocaml
type person = { name : string; age : int; email : string } [@@deriving show]
let alice = { name = "Alice"; age = 30; email = "alice@example.com" }
let person_str = [%show: person] alice  (* 值转字符串 *)
let location = [%here]                  (* 获取源码位置 *)
let port = [%env "PORT"]                (* 获取环境变量 *)
```

### double_percent_examples.ml - %% 扩展示例
演示结构项级别的扩展：
```ocaml
[%%test "addition" = 1 + 1 = 2]         (* 内联测试 *)
[%%ifdef DEBUG then ...]                (* 条件编译 *)
[%%bench "fibonacci 10" = fib 10]       (* 性能基准测试 *)
```

### at_examples.ml - @ 扩展示例
展示模式级别扩展的语法和概念（包含各种 @ 扩展的语法示例）：

#### 1. 正则表达式匹配扩展
```ocaml
let classify_string s =
  match s with
  | _ @regex "^\\d+$" -> "number"        (* 纯数字 *)
  | _ @regex "^[a-zA-Z]+$" -> "letters"  (* 纯字母 *)
  | _ @regex "^[a-zA-Z0-9]+$" -> "alphanumeric" (* 字母数字 *)
  | _ -> "other"
```

#### 2. 范围匹配扩展
```ocaml
let grade_score score =
  match score with
  | _ @range 90 100 -> "A"   (* 90-100分 *)
  | _ @range 80 90 -> "B"    (* 80-89分 *)
  | _ @range 70 80 -> "C"    (* 70-79分 *)
  | _ @range 60 70 -> "D"    (* 60-69分 *)
  | _ -> "F"
```

#### 3. 类型检查扩展
```ocaml
let describe_value v =
  match v with
  | _ @is_int -> "integer: " ^ string_of_int v
  | _ @is_string -> "string: " ^ v
  | _ @is_list -> "list of " ^ string_of_int (List.length v) ^ " items"
  | _ -> "unknown type"
```

#### 4. 验证条件扩展
```ocaml
let validate_user user =
  match user with
  | {name; age; email} @valid (String.length name > 0 &&
                               age >= 18 && age <= 120 &&
                               String.contains email '@') -> true
  | _ -> false
```

#### 5. 模式绑定扩展 (ppx_pattern_bind)
```ocaml
let process_data data =
  match data with
  | _ @bind (x, y) -> x + y  (* 将数据绑定到变量x,y *)
  | _ -> 0
```

#### 6. 数据格式解析扩展
```ocaml
let parse_config config_str =
  match config_str with
  | _ @json -> "JSON格式"    (* JSON解析 *)
  | _ @xml -> "XML格式"      (* XML解析 *)
  | _ @yaml -> "YAML格式"    (* YAML解析 *)
  | _ -> "未知格式"
```

**注意**：这些 @ 扩展语法是概念展示，实际需要对应的 PPX 重写器实现才能工作。

### double_at_examples.ml - @@ 扩展示例
演示类型派生扩展：
```ocaml
type person = { name : string; age : int } [@@deriving show, eq, yojson]
type color = Red | Green | Blue [@@deriving show]
```

### triple_at_examples.ml - @@@ 扩展示例
展示模块级别扩展的完整用法，包括官方内置的 @@@ 扩展和自定义 @@@ 扩展：

#### 🏛️ 官方内置的 @@@ 扩展

##### 1. @@@warning - 警告控制
```ocaml
[@@@warning "+9"]  (* 启用警告9 *)
[@@@warning "-9"]  (* 禁用警告9 *)

module Example = struct
  [@@@warning "-9"]  (* 在模块内禁用警告9 *)
  let code = 42
end
```

##### 2. @@@deprecated - 弃用标记
```ocaml
[@@@deprecated "Use NewModule instead"]
module OldModule = struct ... end
```

##### 3. @@@inline - 内联控制
```ocaml
[@@@inline]  (* 强制内联模块中的函数 *)
module FastModule = struct
  [@@@inline never]  (* 特定函数不内联 *)
  let slow_function x = x
end
```

##### 4. @@@specialise - 特化控制
```ocaml
[@@@specialise]  (* 允许函数特化 *)
module GenericModule = struct
  [@@@specialise never]  (* 禁止特化 *)
  let generic f x = f x
end
```

#### 🛠️ 自定义 @@@ 扩展（需要重写器）

##### 5. 模块包装扩展 (@wrapped) - 自定义
```ocaml
module Calculator @@@ wrapped = struct
  let add x y = x + y
end
(* 自动添加 __wrapped_module 标识 *)
```

##### 6. 性能计时扩展 (@timed) - 自定义
```ocaml
module Math @@@ timed = struct
  let fibonacci n = (* 计算斐波那契数列 *)
end
(* 自动为所有函数添加执行时间测量 *)
```

##### 7. 日志记录扩展 (@logged) - 自定义
```ocaml
module Database @@@ logged = struct
  let connect host port = (* 连接数据库 *)
end
(* 自动记录所有函数的调用和返回 *)
```

##### 8. 缓存扩展 (@cached) - 自定义
```ocaml
module Computation @@@ cached = struct
  let expensive_calc x = (* 耗时的计算 *)
end
(* 自动缓存纯函数的结果 *)
```

**文件包含完整的官方 @@@ 扩展示例和可运行的自定义扩展演示**

### triple_percent_examples.ml - %%% 扩展示例
展示文件级别扩展的实际语法和概念（包含完整的 [%%%module_wrapper] 语法示例）：
```ocaml
(** 文件顶部直接使用 %%% 扩展语法：*)
[%%%module_wrapper {
  (** 这里是使用 %%%module_wrapper 扩展包装的实际代码 *)

  type person = { name : string; age : int; email : string; }

  let create_person name age email = { name; age; email; }

  let greet_person p = Printf.printf "Hello, %s!\n" p.name

  let main () = (* ... 实际代码 ... *)
  let () = main ()
}]
```
**注意**：文件顶部有实际的 `[%%%module_wrapper {...}]` 语法块！

### triple_percent_examples.mli - %%% 扩展详细说明
接口文件，包含完整的 [%%%module_wrapper] 语法示例（在 .mli 文件中的实际使用）和转换结果说明。

## 运行示例

### 单个示例运行
```bash
# 运行综合示例（展示所有扩展类型）
dune exec ./ppxstudy/examples/run_examples.exe

# 运行 % 扩展示例（表达式级别扩展）
dune exec ./ppxstudy/examples/percent_examples.exe

# 运行 %% 扩展示例（结构项级别扩展）
dune exec ./ppxstudy/examples/double_percent_examples.exe

# 运行 @ 扩展示例（模式级别扩展）
dune exec ./ppxstudy/examples/at_examples.exe

# 运行 @@ 扩展示例（类型级别扩展）
dune exec ./ppxstudy/examples/double_at_examples.exe

# 运行 @@@ 扩展示例（模块级别扩展）
dune exec ./ppxstudy/examples/triple_at_examples.exe

# 运行 %%% 扩展示例（文件级别扩展）
dune exec ./ppxstudy/examples/triple_percent_examples.exe
```

### 批量运行所有示例
```bash
# 逐个运行所有示例
for example in run_examples percent_examples double_percent_examples at_examples double_at_examples triple_at_examples triple_percent_examples; do
  echo "=== 运行 $example ==="
  dune exec ./ppxstudy/examples/$example.exe
  echo ""
done
```

## 注意事项

1. **第三方库扩展**：示例中展示了 `ppx_deriving`、`ppx_here`、`ppx_env` 等第三方库提供的扩展语法（但未实际配置使用）
2. **安装依赖**：
   ```bash
   opam install ppx_deriving ppx_here ppx_env ppx_inline_test ppx_expect
   opam install ppx_yojson_conv ppx_sexp_conv ppx_here ppx_env
   ```
3. **自定义扩展**：`rewriters/` 目录中的重写器实现了自定义扩展
4. **学习顺序**：建议按 `%` → `%%` → `@` → `@@` → `@@@` 的顺序学习

## @ 扩展详解

@ 扩展是模式级别的 PPX 扩展，用于增强 OCaml 的模式匹配能力。虽然 OCaml 官方没有内置的 @ 扩展，但可以通过自定义 PPX 重写器实现各种强大的模式匹配功能。

### @ 扩展的基本语法

```ocaml
pattern @ extension_name arguments
```

其中：
- `pattern` 是标准的 OCaml 模式（如变量、构造函数等）
- `@` 是扩展操作符
- `extension_name` 是扩展的名字
- `arguments` 是传递给扩展的参数

### @ 扩展的分类

#### 🛠️ **自定义教学示例**（需要实现对应的 PPX 重写器）

##### 1. 正则表达式匹配 (`@regex`) - 自定义

```ocaml
let classify_string s =
  match s with
  | _ @regex "^\\d+$" -> "纯数字"
  | _ @regex "^[a-zA-Z]+$" -> "纯字母"
  | _ @regex "^[a-zA-Z0-9]+$" -> "字母数字混合"
  | _ -> "其他"
```

**实现方式**：转换为 `Str.string_match` 调用

##### 2. 范围匹配 (`@range`) - 自定义

```ocaml
let grade_score score =
  match score with
  | _ @range 90 100 -> "优秀"
  | _ @range 80 90 -> "良好"
  | _ @range 70 80 -> "中等"
  | _ @range 60 70 -> "及格"
  | _ -> "不及格"
```

**实现方式**：转换为数值范围比较

##### 3. 类型检查 (`@is_type`) - 自定义

```ocaml
let describe_value v =
  match v with
  | _ @is_int -> "整数"
  | _ @is_string -> "字符串"
  | _ @is_list -> "列表"
  | _ -> "其他类型"
```

**实现方式**：使用 `Obj` 魔术进行运行时类型检查

##### 4. 验证条件 (`@valid`) - 自定义

```ocaml
let validate_user user =
  match user with
  | {name; age; email} @valid (age >= 18 && String.contains email '@') -> "有效用户"
  | _ -> "无效用户"
```

**实现方式**：转换为额外的 `when` 条件

##### 5. 数据格式解析 (`@json`, `@xml`, `@yaml`) - 自定义

```ocaml
let parse_config config_str =
  match config_str with
  | _ @json -> "JSON格式"    (* JSON解析 *)
  | _ @xml -> "XML格式"      (* XML解析 *)
  | _ @yaml -> "YAML格式"    (* YAML解析 *)
  | _ -> "未知格式"
```

**实现方式**：自动格式识别和解析

#### 📦 **第三方库提供的 @ 扩展**

##### 6. 模式绑定 (`@bind`) - ppx_pattern_bind

```ocaml
let process_data data =
  match data with
  | _ @bind (x, y) -> x + y  (* 将数据绑定到变量x,y *)
  | _ -> 0
```

**提供者**：`ppx_pattern_bind` 第三方库
**用途**：复杂的模式解构和赋值

## 第三方 @ 扩展的完整使用指南

### ppx_pattern_bind 库使用步骤

#### 1. 安装库（必须步骤）

```bash
# 安装第三方库
opam install ppx_pattern_bind
```

#### 2. 检查安装是否成功

```bash
# 查看已安装的包
opam list | grep ppx_pattern_bind

# 或者查看包信息
opam show ppx_pattern_bind
```

#### 3. 配置 Dune 文件（推荐方式）

在你的项目 `dune` 文件中添加：

```lisp
(executable
 (name my_program)
 (libraries core)  ; 你的其他库
 (preprocess (pps ppx_pattern_bind))  ; 添加 PPX 重写器
 (modules my_program))
```

#### 4. 或者直接使用命令行（替代方式）

```bash
# 编译时指定重写器
ocamlc -ppx 'ppx_pattern_bind' my_file.ml
```

#### 5. 在代码中启用和使用

```ocaml
(* 文件顶部启用扩展 *)
[@@bind]

(* 现在可以使用 @bind 扩展 *)
let process_pair data =
  match data with
  | _ @bind (x, y) -> x + y  (* 自动解构元组 *)
  | _ -> 0

(* 使用示例 *)
let result = process_pair (3, 7)  (* 返回 10 *)
```

#### 6. 测试扩展是否工作

```bash
# 编译测试
dune build

# 如果编译成功，说明扩展正常工作
dune exec ./my_program.exe
```

### 其他第三方 @ 扩展库

如果你找到其他提供 @ 扩展的库，使用步骤类似：

1. **安装库**：`opam install library_name`
2. **配置 Dune**：添加 `(pps library_name)` 到 preprocess
3. **按文档使用**：查看库的文档了解具体语法

### 注意事项

#### 对于自定义 @ 扩展：
- ✅ **必须实现对应的 PPX 重写器**
- ✅ **需要构建重写器**
- ✅ **需要在 Dune 中配置或命令行指定**

#### 对于第三方 @ 扩展：
- ✅ **需要安装对应的 opam 包**
- ✅ **需要在 Dune 中配置或命令行指定**
- ✅ **按照库文档使用正确的语法**

#### 常见错误排查：

```bash
# 如果编译失败，检查重写器是否正确配置
dune build --verbose

# 检查 opam 包是否正确安装
opam list | grep ppx

# 查看 Dune 缓存
dune clean && dune build
```

### 实际操作示例（新手友好）

#### 示例1：使用第三方 @ 扩展

1. **创建新项目**：
```bash
mkdir my_ppx_test
cd my_ppx_test
```

2. **创建 dune-project 文件**：
```lisp
(lang dune 3.8)
(name my_ppx_test)
```

3. **安装依赖**：
```bash
opam install ppx_pattern_bind core
```

4. **创建 dune 文件**：
```lisp
(executable
 (name test)
 (libraries core)
 (preprocess (pps ppx_pattern_bind))
 (modules test))
```

5. **创建 test.ml 文件**：
```ocaml
[@@bind]

let add_pair data =
  match data with
  | _ @bind (x, y) -> x + y
  | _ -> 0

let () =
  let result = add_pair (3, 7) in
  Printf.printf "Result: %d\n" result
```

6. **构建和运行**：
```bash
dune build
dune exec ./test.exe
# 输出: Result: 10
```

#### 示例2：使用自定义 @ 扩展

1. **复制项目中的重写器**：
```bash
cp /path/to/ppxstudy/rewriters/ppx_regex.ml ./ppx_regex.ml
```

2. **创建重写器库的 dune 文件**：
```lisp
(library
 (name ppx_regex_lib)
 (libraries ppxlib)
 (preprocess (pps ppxlib.metaquot))
 (modules ppx_regex))
```

3. **修改主程序的 dune 文件**：
```lisp
(executable
 (name test)
 (libraries core str)
 (preprocess (pps ppx_regex_lib))
 (modules test))
```

4. **在 test.ml 中使用**：
```ocaml
let classify s =
  match s with
  | _ @regex "^\\d+$" -> "数字"
  | _ @regex "^[a-zA-Z]+$" -> "字母"
  | _ -> "其他"

let () =
  print_endline (classify "123");
  print_endline (classify "abc");
  print_endline (classify "hello!")
```

5. **构建和运行**：
```bash
dune build
dune exec ./test.exe
```

### 学习路径建议

1. **先掌握基本 PPX 概念**（% 扩展）
2. **学习官方扩展**（@@deriving）
3. **尝试第三方扩展**（@bind）
4. **实现自己的扩展**（自定义 @ 扩展）

### 常见问题解答

**Q: 为什么我的 @ 扩展不工作？**
A: 检查是否正确配置了 Dune 文件中的 `(pps ...)` 部分

**Q: 如何知道某个 @ 扩展是否可用？**
A: 查看项目的依赖和已安装的 opam 包

**Q: 自定义扩展和第三方扩展有什么区别？**
A: 自定义扩展需要你自己实现重写器，第三方扩展只需要安装包

这样你就能从简单到复杂地掌握 PPX 扩展的使用了！🚀

### 自定义 @ 扩展实现

项目中的 `rewriters/ppx_regex.ml` 实现了 `@regex` 扩展作为教学示例。要实现自定义 @ 扩展：

1. **创建重写器**：
```ocaml
let my_extension =
  Extension.declare
    "my_ext"                           (* 扩展名 *)
    Extension.Context.pattern          (* 模式上下文 *)
    Ast_pattern.(single_expr_payload __) (* 参数模式 *)
    (fun ~loc ~path:_ expr ->
       (* 转换逻辑 *)
       Ast_helper.Pat.when_ var_pat when_expr
    )
```

2. **注册扩展**：
```ocaml
let () = Driver.register_transformation "my_ext" ~extensions:[my_extension]
```

3. **使用扩展**：
```bash
ocamlc -ppx './my_rewriter.exe' my_file.ml
```

### 自定义 @ 扩展的完整使用流程

#### 1. 实现重写器（必须步骤）

首先需要创建 PPX 重写器，例如 `ppx_regex.ml`：

```ocaml
(* ppx_regex.ml *)
open Ppxlib

let regex_extension =
  Extension.declare
    "regex"                            (* 扩展名 *)
    Extension.Context.pattern          (* 模式上下文 *)
    Ast_pattern.(single_expr_payload __) (* 参数模式 *)
    (fun ~loc ~path:_ expr ->
       (* 转换逻辑：将 @regex 转换为 when 条件 *)
       let var_pat = Ast_helper.Pat.var {txt = "_regex_match"; loc} in
       let when_expr = [%expr
         try
           let regexp = Str.regexp [%e expr] in
           Str.string_match regexp _regex_match 0
         with _ -> false
       ] in
       Ast_helper.Pat.when_ var_pat when_expr
    )

let () = Driver.register_transformation "regex" ~extensions:[regex_extension]
```

#### 2. 构建重写器（必须步骤）

```bash
# 构建自定义重写器
dune build ppxstudy/rewriters
```

#### 3. 配置 Dune 文件（推荐方式）

在你的项目 `dune` 文件中添加：

```lisp
; 在可执行文件配置中添加
(executable
 (name my_program)
 (libraries core str)  ; 包含需要的库
 (preprocess (pps ppx_study_rewriters))  ; 使用自定义重写器
 (modules my_program))
```

#### 4. 或者直接使用命令行（替代方式）

```bash
# 编译时直接指定重写器
ocamlc -ppx './ppx_study_rewriters.exe' my_file.ml
```

#### 5. 使用扩展

现在你就可以在代码中使用自定义的 @ 扩展了：

```ocaml
let classify_string s =
  match s with
  | _ @regex "^\\d+$" -> "数字"      (* 会正常工作 *)
  | _ @regex "^[a-zA-Z]+$" -> "字母" (* 会正常工作 *)
  | _ -> "其他"
```

### 注意事项

1. **性能影响**：@ 扩展通常涉及运行时检查，可能影响性能
2. **错误处理**：需要妥善处理匹配失败的情况
3. **组合使用**：可以与 when 条件结合使用
4. **调试困难**：扩展后的代码可能与原始代码差异较大

### 实际应用场景

- **输入验证**：使用 `@valid` 进行复杂的数据验证
- **格式识别**：使用 `@regex` 或 `@json` 等进行数据格式检测
- **范围检查**：使用 `@range` 进行数值范围验证
- **类型分派**：使用 `@is_type` 进行运行时类型检查
- **模式解构**：使用 `@bind` 进行复杂的数据解构

## @@@ 扩展详解

@@@ 扩展是模块级别的属性扩展，用于控制编译器的行为和代码的编译方式。OCaml 官方内置了很多 @@@ 扩展，同时也可以通过自定义 PPX 重写器实现额外的模块级变换功能。

### @@@ 扩展的基本语法

```ocaml
module ModuleName @@@ extension_name = struct
  (* 模块内容 *)
end
```

或者：

```ocaml
[@@@extension_name
module ModuleName = struct
  (* 模块内容 *)
end]
```

其中：
- `module ModuleName` 是标准的模块定义
- `@@@` 是扩展操作符
- `extension_name` 是扩展的名字
- 扩展会自动变换模块的内部结构

### OCaml 官方内置的 @@@ 扩展

OCaml 编译器内置了很多 @@@ 扩展，主要用于控制编译器的行为：

#### 1. @@@warning - 警告控制

```ocaml
[@@@warning "+9"]   (* 启用警告9 *)
[@@@warning "-9"]   (* 禁用警告9 *)
[@@@warning "+9-27"] (* 同时控制多个警告 *)
```

**位置**：文件顶部或模块内部
**作用**：控制特定警告的启用/禁用

#### 2. @@@deprecated - 弃用标记

```ocaml
[@@@deprecated "Use new_module instead"]
module OldModule = struct ... end
```

**位置**：模块定义前
**作用**：标记模块或函数为已弃用

#### 3. @@@alert - 警报标记

```ocaml
[@@@alert unsafe "Contains unsafe operations"]
[@@@alert "-unsafe"]  (* 禁用特定警报 *)
```

**位置**：模块定义前
**作用**：标记代码中的潜在问题

#### 4. @@@inline - 内联控制

```ocaml
[@@@inline]           (* 强制内联 *)
[@@@inline never]     (* 从不内联 *)
[@@@inline always]    (* 总是内联 *)
[@@@inline hint]      (* 内联建议 *)
```

**位置**：模块或函数前
**作用**：控制函数的内联行为

#### 5. @@@specialise - 特化控制

```ocaml
[@@@specialise]       (* 允许特化 *)
[@@@specialise never] (* 禁止特化 *)
[@@@specialise always](* 强制特化 *)
```

**位置**：模块或函数前
**作用**：控制多态函数的特化

#### 6. @@@local - 本地分配控制

```ocaml
[@@@local]            (* 允许本地分配 *)
[@@@local never]      (* 禁止本地分配 *)
[@@@local always]     (* 强制本地分配 *)
```

**位置**：模块或函数前
**作用**：控制变量的分配策略

#### 7. @@@tailcall - 尾调用控制

```ocaml
[@@@tailcall true]    (* 启用尾调用优化 *)
[@@@tailcall false]   (* 禁用尾调用优化 *)
```

**位置**：函数前
**作用**：控制尾调用优化

#### 8. @@@unbox/@unboxed - 装箱控制

```ocaml
[@@@unboxed]          (* 取消装箱 *)
[@@@unbox]            (* 控制装箱行为 *)
type t = int [@@unboxed]  (* 具体类型取消装箱 *)
```

**位置**：类型定义前
**作用**：控制数据类型的装箱行为

### 官方 @@@ 扩展的使用位置

```ocaml
(* 文件级别 - 影响整个文件 *)
[@@@warning "+9"]
[@@@alert unsafe "file description"]

(* 模块级别 - 影响整个模块 *)
module M = struct
  [@@@deprecated "use N instead"]
  [@@@inline]

  (* 函数级别 - 只影响特定函数 *)
  [@@@specialise never]
  let f x = x
end

(* 类型级别 - 影响类型定义 *)
[@@@unboxed]
type t = int
```

### 官方 @@@ 扩展的语法规则

1. **位置敏感**：有些扩展只在特定位置有效
2. **作用域**：扩展的影响范围从定义点开始
3. **可嵌套**：内部定义可以覆盖外部设置
4. **编译时生效**：在编译时影响代码生成，而非运行时

### 常见的 @@@ 扩展类型

#### 1. 模块包装扩展 (@wrapped) - 自定义

```ocaml
module Calculator @@@ wrapped = struct
  let add x y = x + y
  let multiply x y = x * y
end

(* 编译转换：添加包装标识 *)
module Calculator = struct
  let __wrapped_module = "wrapped"  (* 自动添加 *)
  let add x y = x + y
  let multiply x y = x * y
end
```

#### 2. 性能计时扩展 (@timed) - 自定义

```ocaml
module Math @@@ timed = struct
  let fibonacci n = (* 斐波那契计算 *)
  let factorial n = (* 阶乘计算 *)
end

(* 编译转换：自动添加时间测量 *)
module Math = struct
  let fibonacci n =
    let start = Unix.gettimeofday () in
    let result = (* 原始逻辑 *) in
    let elapsed = Unix.gettimeofday () -. start in
    Printf.printf "[TIME] fibonacci took %.6f seconds\n" elapsed;
    result
  (* factorial 类似处理 *)
end
```

#### 3. 日志记录扩展 (@logged) - 自定义

```ocaml
module Database @@@ logged = struct
  let connect host port = (* 连接逻辑 *)
  let query sql = (* 查询逻辑 *)
end

(* 编译转换：自动添加调用日志 *)
module Database = struct
  let connect host port =
    Printf.printf "[LOG] connect called\n";
    let result = (* 原始逻辑 *) in
    Printf.printf "[LOG] connect returned\n";
    result
  (* query 类似处理 *)
end
```

#### 4. 缓存扩展 (@cached) - 自定义

```ocaml
module Computation @@@ cached = struct
  let expensive_calc x = (* 耗时计算 *)
  let complex_function y = (* 复杂计算 *)
end

(* 编译转换：自动添加结果缓存 *)
module Computation = struct
  let expensive_calc_cache = Hashtbl.create 16  (* 自动添加 *)
  let expensive_calc x =
    try Hashtbl.find expensive_calc_cache x
    with Not_found ->
      let result = (* 原始逻辑 *) in
      Hashtbl.add expensive_calc_cache x result;
      result
  (* complex_function 类似处理 *)
end
```

### 第三方 @@@ 扩展库

目前 OCaml 生态系统中还没有广泛使用的 @@@ 扩展库。大部分 @@@ 扩展都是自定义实现的。

### 实现自定义 @@@ 扩展

```ocaml
let wrapped_extension =
  Extension.declare
    "wrapped"                         (* 扩展名 *)
    Extension.Context.module_expr      (* 模块上下文 *)
    Ast_pattern.(__)                  (* 匹配任意模块 *)
    (fun ~loc ~path:_ module_expr ->
       (* 转换逻辑 *)
       match module_expr.pmod_desc with
       | Pmod_structure structure_items ->
           (* 添加包装标识 *)
           let wrapper_item = Ast_helper.Str.value Nonrecursive [
             Ast_helper.Vb.mk
               (Ast_helper.Pat.var {txt = "__wrapped_module"; loc})
               (Ast_helper.Exp.constant (Const.string "wrapped"))
           ] in
           Ast_helper.Mod.structure (wrapper_item :: structure_items)
       | _ -> module_expr
    )
```

### 使用自定义 @@@ 扩展

1. **实现重写器**：
```bash
# 实现 ppx_wrapped.ml 等
```

2. **构建重写器**：
```bash
dune build ppxstudy/rewriters
```

3. **配置项目**：
```lisp
(executable
 (name my_app)
 (preprocess (pps ppx_study_rewriters))  ; 使用重写器
 (modules my_app))
```

4. **在代码中使用**：
```ocaml
module MyModule @@@ wrapped = struct
  (* 模块内容 *)
end
```

### 注意事项

1. **模块级变换**：@@@ 扩展会改变整个模块的结构
2. **AOP 概念**：@@@ 扩展实现了面向切面编程的思想
3. **性能影响**：某些扩展（如计时、日志）会影响运行时性能
4. **调试复杂性**：扩展后的模块结构可能与原始代码差异较大
5. **组合使用**：可以同时使用多个 @@@ 扩展

### 实际应用场景

- **性能监控**：使用 `@timed` 监控函数执行时间
- **调试支持**：使用 `@logged` 添加详细的调用日志
- **缓存优化**：使用 `@cached` 自动缓存计算结果
- **模块包装**：使用 `@wrapped` 添加模块元信息
- **安全检查**：使用自定义扩展添加安全验证
- **代码生成**：使用扩展自动生成样板代码

### 学习建议

1. **理解模块系统**：掌握 OCaml 的模块和函子
2. **学习 AST 操作**：理解如何修改模块结构
3. **实现简单扩展**：从 `@wrapped` 开始
4. **添加复杂功能**：实现 `@timed` 和 `@logged`
5. **优化性能**：实现 `@cached` 等优化扩展

现在你应该对 @@@ 扩展有了完整的理解！🚀

## 扩展类型总结

| 符号 | 位置 | 示例 | 用途 | 文件示例 |
|------|------|------|------|----------|
| `%` | 表达式中 | `[%show: type] value` | 数据转换、调试 | percent_examples.ml |
| `%%` | 顶层声明间 | `[%%test "name"]` | 测试、条件编译 | double_percent_examples.ml |
| `%%%` | 整个文件 | `[%%%module_wrapper]` | 文件级转换 | triple_percent_examples.ml + .mli |
| `@` | 模式匹配中 | `_ @regex "pattern"` | 模式匹配增强 | at_examples.ml |
| `@@` | 类型定义后 | `[@@deriving show]` | 类型派生 | double_at_examples.ml |
| `@@@` | 模块/文件级别 | `[@@@warning "+9"]` 或 `module M @@@ wrapped` | 编译控制/模块变换 | triple_at_examples.ml |

**重要说明**：
- `%%%` 扩展可以同时在 `.ml` 和 `.mli` 文件中使用
- 通常在两个文件中都使用相同的 `%%%` 扩展以保持一致性
- `.mli` 文件中的 `%%%` 定义接口，`.ml` 文件中的 `%%%` 提供实现
- `@@@` 扩展包括官方内置的（如 `@warning`, `@deprecated`）和自定义的（如 `@wrapped`, `@timed`）
- 官方 `@@@` 扩展主要控制编译器行为，自定义 `@@@` 扩展用于模块变换
