# PPX 重写器详解

这个目录包含了各种自定义 PPX 重写器的实现，每个重写器演示了不同类型的 PPX 扩展。

## 重写器列表

### 1. ppx_debug.ml - %debug 扩展（表达式级别）

**功能**：为表达式添加调试输出功能

**语法**：
```ocaml
[%debug expression]
```

**示例**：
```ocaml
let result = [%debug 1 + 2 + 3]  (* 会打印表达式的值 *)
```

**转换结果**：
```ocaml
let result =
  Printf.printf "🐛 [DEBUG] 表达式: %s\n" "1 + 2 + 3";
  let result = 1 + 2 + 3 in
  Printf.printf "🐛 [DEBUG] 结果: %s\n" "6";
  result
```

---

### 2. ppx_calc.ml - %calc 扩展（表达式级别）

**功能**：在编译时进行数学计算

**语法**：
```ocaml
[%calc expression]
```

**示例**：
```ocaml
let area = [%calc 3.14 * r * r]  (* 编译时计算 *)
```

**用途**：避免运行时计算，提升性能

---

### 3. ppx_log.ml - %log 扩展（表达式级别）

**功能**：为表达式执行添加日志记录

**语法**：
```ocaml
[%log expression]
```

**示例**：
```ocaml
let data = [%log load_data_from_file "input.txt"]
```

**转换结果**：
```ocaml
let data =
  Printf.printf "[LOG] Executing expression at %s\n" "file.ml:42";
  let result = load_data_from_file "input.txt" in
  Printf.printf "[LOG] Expression result: %s\n" "<value>";
  result
```

---

### 4. ppx_auto.ml - %%auto 扩展（结构项级别）

**功能**：为类型定义自动生成辅助函数

**语法**：
```ocaml
[%%auto {
  type color = Red | Green | Blue
  type point = { x : int; y : int }
}]
```

**生成的代码**：
```ocaml
(* 为变体类型生成 *)
let to_string = function Red -> "Red" | Green -> "Green" | Blue -> "Blue"
let of_string = function "Red" -> Red | "Green" -> Green | "Blue" -> Blue | _ -> failwith "..."

(* 为记录类型生成 *)
let get_x r = r.x
let get_y r = r.y
```

---

### 5. ppx_module_wrapper.ml - %%%module_wrapper 扩展（文件级别）

**功能**：将整个文件包装在模块中

**语法**：
```ocaml
[%%%module_wrapper {
  let x = 42
  let y = "hello"
  let add a b = a + b
}]
```

**转换结果**：
```ocaml
module WrappedModule = struct
  let x = 42
  let y = "hello"
  let add a b = a + b
end

open WrappedModule
```

---

### 6. ppx_regex.ml - @regex 扩展（模式级别）

**功能**：在模式匹配中使用正则表达式

**语法**：
```ocaml
match str with
| _ when Str.string_match (Str.regexp pattern) str 0 -> "匹配"
```

**概念示例**：
```ocaml
match str with
| _ @ regex "^\\d+$" -> "数字"
| _ @ regex "^[a-zA-Z]+$" -> "字母"
| _ -> "其他"
```

---

### 7. ppx_alias.ml - @@alias 扩展（类型级别）

**功能**：为类型添加别名属性

**语法**：
```ocaml
type person @@ alias "Person" = {
  name : string;
  age : int;
}
```

**用途**：类型系统集成、元数据记录

---

### 8. ppx_wrapped.ml - @@@wrapped 扩展（模块级别）

**功能**：为模块添加包装功能

**语法**：
```ocaml
module Calculator [@@@wrapped] = struct
  let add x y = x + y
end
```

**转换结果**：
```ocaml
module Calculator = struct
  let __wrapped_module = "wrapped"
  let add x y = x + y
end
```

## 编译和使用

### 构建重写器

```bash
dune build ppxstudy/rewriters
```

### 使用重写器

```bash
# 编译时使用
ocamlc -ppx './ppx_study_rewriters.exe' your_file.ml

# 或在 dune 中配置
(preprocess (pps ppx_study_rewriters))
```

## 学习重点

1. **表达式级别扩展** (`%`)：处理单个表达式
2. **结构项级别扩展** (`%%`)：处理顶层声明
3. **文件级别扩展** (`%%%`)：处理整个文件
4. **模式级别扩展** (`@`)：增强模式匹配
5. **类型级别扩展** (`@@`)：处理类型定义
6. **模块级别扩展** (`@@@`)：处理模块定义

## 实现要点

- 使用 `Extension.declare` 注册扩展
- 指定扩展上下文（`Extension.Context.*`）
- 使用 `Ast_pattern` 匹配语法结构
- 使用 `Ast_helper` 构造新的 AST
- 使用 `metaquot` (`[%expr ...]`) 创建代码模板
