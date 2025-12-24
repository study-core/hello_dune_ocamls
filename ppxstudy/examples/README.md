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
展示模式匹配增强（使用传统方法模拟）：
```ocaml
let classify_string s =
  match s with
  | _ when Str.string_match (Str.regexp "^\\d+$") s 0 -> "number"
  | _ when Str.string_match (Str.regexp "^[a-zA-Z]+$") s 0 -> "letters"
  | _ -> "mixed"
```

### double_at_examples.ml - @@ 扩展示例
演示类型派生扩展：
```ocaml
type person = { name : string; age : int } [@@deriving show, eq, yojson]
type color = Red | Green | Blue [@@deriving show]
```

### triple_at_examples.ml - @@@ 扩展示例
展示模块级别的扩展使用。

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

1. **官方扩展**：示例中使用了 `ppx_deriving`、`ppx_here`、`ppx_env` 等官方包提供的扩展
2. **安装依赖**：
   ```bash
   opam install ppx_deriving ppx_inline_test ppx_expect
   opam install ppx_yojson_conv ppx_sexp_conv ppx_here ppx_env
   ```
3. **自定义扩展**：`rewriters/` 目录中的重写器实现了自定义扩展
4. **学习顺序**：建议按 `%` → `%%` → `@` → `@@` → `@@@` 的顺序学习

## 扩展类型总结

| 符号 | 位置 | 示例 | 用途 | 文件示例 |
|------|------|------|------|----------|
| `%` | 表达式中 | `[%show: type] value` | 数据转换、调试 | percent_examples.ml |
| `%%` | 顶层声明间 | `[%%test "name"]` | 测试、条件编译 | double_percent_examples.ml |
| `%%%` | 整个文件 | `[%%%module_wrapper]` | 文件级转换 | triple_percent_examples.ml + .mli |
| `@` | 模式匹配中 | 增强模式匹配能力 | 模式匹配增强 | at_examples.ml |
| `@@` | 类型定义后 | `[@@deriving show]` | 类型派生 | double_at_examples.ml |
| `@@@` | 模块定义中 | `[@@@wrapped]` | 模块变换 | triple_at_examples.ml |

**重要说明**：
- `%%%` 扩展可以同时在 `.ml` 和 `.mli` 文件中使用
- 通常在两个文件中都使用相同的 `%%%` 扩展以保持一致性
- `.mli` 文件中的 `%%%` 定义接口，`.ml` 文件中的 `%%%` 提供实现
