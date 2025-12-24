(** 自定义 PPX 重写器：@is_type 扩展
    演示如何实现运行时类型检查的模式扩展

    这个扩展允许在模式匹配中进行运行时类型检查
*)

open Ppxlib

(** ==================== 辅助函数 ==================== *)

(** 获取类型标签的字符串表示 *)
let type_name_of_string = function
  | "int" -> "Obj.int_tag"
  | "string" -> "Obj.string_tag"
  | "float" -> "Obj.double_tag"
  | "bool" -> "Obj.custom_tag"  (* 近似处理 *)
  | "list" -> "Obj.block_tag"   (* 列表是块 *)
  | _ -> failwith "Unsupported type for @is_type"

(** ==================== 扩展注册 ==================== *)

(** 注册 @is_type 扩展
    语法：_ @is_int, _ @is_string, _ @is_list 等

    这个扩展会将类型检查转换为 when 条件

    生成的代码示例：
    输入：  | _ @is_int -> "integer"
           | _ @is_string -> "string"

    输出：  | _type_match when Obj.tag (Obj.repr _type_match) = Obj.int_tag -> "integer"
           | _type_match when Obj.tag (Obj.repr _type_match) = Obj.string_tag -> "string"
*)

let create_is_type_extension type_name =
  Extension.declare
    ("is_" ^ type_name)               (* 扩展的名字，如 is_int *)
    Extension.Context.pattern         (* 扩展的上下文：模式 *)
    Ast_pattern.(pstr nil)           (* 不需要参数 *)
    (fun ~loc ~path:_ () ->
       (* 创建一个变量模式来绑定匹配的值 *)
       let var_pat = Ast_helper.Pat.var {txt = "_type_match"; loc} in

       (* 创建 when 条件：检查运行时类型 *)
       let type_tag = type_name_of_string type_name in
       let when_expr = [%expr
         Obj.tag (Obj.repr _type_match) = [%e Ast_helper.Exp.ident {txt = Longident.parse type_tag; loc}]
       ] in

       (* 返回带条件的模式 *)
       Ast_helper.Pat.when_ var_pat when_expr
    )

(** 注册所有支持的类型检查扩展 *)
let int_extension = create_is_type_extension "int"
let string_extension = create_is_type_extension "string"
let float_extension = create_is_type_extension "float"
let bool_extension = create_is_type_extension "bool"
let list_extension = create_is_type_extension "list"

(** 注册重写器 *)
let () = Driver.register_transformation "is_type" ~extensions:[
  int_extension;
  string_extension;
  float_extension;
  bool_extension;
  list_extension;
]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    type value = Int_val of int | String_val of string | List_val of value list

    let describe_value v =
      match v with
      | _ @is_int -> "整数"
      | _ @is_string -> "字符串"
      | _ @is_list -> "列表"
      | _ -> "其他类型"

    (* 注意：这个扩展检查的是运行时类型，不是构造器类型
       对于上面的例子，Int_val 42 会被识别为整数，
       而不是作为构造器模式匹配
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 @is_type 扩展演示了：

    1. 如何创建多个相关的模式扩展
    2. 如何使用 Obj 魔术进行运行时类型检查
    3. 如何处理无参数的模式扩展
    4. 如何批量注册多个扩展

    注意：这只是教学示例，实际使用时需要谨慎处理类型检查的安全性
*)
