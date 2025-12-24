(** 自定义 PPX 重写器：@@alias 扩展
    演示如何创建类型级别的 PPX 扩展

    这个扩展为类型添加别名属性

    注意：虽然这是@@扩展，但实际的@@扩展通常由第三方库如ppx_deriving提供。
    ppx_deriving.show 生成的代码示例：
    输入：  type person = { name : string; age : int } [@@deriving show]

    输出：  type person = { name : string; age : int }
           let pp_person fmt v = Fmt.pf fmt "{ name = %S; age = %d }" v.name v.age
           let show_person v = Format.asprintf "%a" pp_person v
*)

open Ppxlib

(** ==================== 扩展注册 ==================== *)

(** 注册 @@alias 扩展
    语法：type t @@ alias "AliasName" = ...

    这个扩展会为类型添加别名属性（概念演示）
*)

let alias_extension =
  Extension.declare
    "alias"                         (* 扩展的名字 *)
    Extension.Context.type_expr     (* 扩展的上下文：类型表达式 *)
    Ast_pattern.(single_expr_payload __)  (* 匹配单个表达式（别名字符串） *)
    (fun ~loc ~path:_ alias_expr ->
       (* 在这个简化版本中，我们只是返回原始类型
          实际实现中可以添加属性或其他转换 *)
       match alias_expr.pexp_desc with
       | Pexp_constant (Pconst_string (alias_name, _, _)) ->
           (* 这里可以添加别名属性或进行其他转换 *)
           Printf.printf "类型别名: %s\n" alias_name;
           (* 返回原始类型，这里应该返回转换后的类型 *)
           failwith "@@alias 扩展需要根据具体需求实现类型转换"
       | _ ->
           failwith "@@alias 需要字符串字面量作为参数"
    )

(** 注册重写器 *)
let () = Driver.register_transformation "alias" ~extensions:[alias_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    type person @@ alias "Person" = {
      name : string;
      age : int;
      email : string;
    }

    type int @@ alias "Integer" = int
    type string @@ alias "String" = string

    (* 概念上，这个扩展可以：
       1. 在编译时记录类型别名
       2. 生成额外的元数据
       3. 进行类型映射或转换
       4. 生成序列化/反序列化函数
    *)

*)

(** ==================== 注意事项 ==================== *)

(** 1. 这个实现是不完整的
    @@alias 扩展的具体行为取决于你的需求

    2. 类型级别的扩展可以：
    - 添加类型属性
    - 生成额外代码
    - 修改类型定义
    - 创建类型映射

    3. 实际应用中，可能需要：
    - 代码生成
    - 元数据收集
    - 类型转换
    - 文档生成
*)

(** ==================== 扩展说明 ==================== *)

(** 这个 @@alias 扩展演示了：

    1. 如何创建类型级别的扩展
    2. 如何处理类型定义的属性
    3. 如何根据扩展参数进行不同的处理
    4. 类型扩展的框架结构

    类型级别的扩展常用于代码生成和元编程
*)
