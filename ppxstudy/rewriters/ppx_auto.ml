(** 自定义 PPX 重写器：%%auto 扩展
    演示如何创建结构项级别的 PPX 扩展

    这个扩展会为类型定义自动生成辅助函数
*)

open Ppxlib

(** ==================== 处理类型定义 ==================== *)

(** 为变体类型生成辅助函数 *)
let generate_helpers_for_variant ~loc type_name constructors =
  (* 生成构造函数列表 *)
  let constructor_names = List.map (fun (c : Parsetree.constructor_declaration) -> c.pcd_name.txt) constructors in

  (* 生成 to_string 函数 *)
  let to_string_cases =
    List.map (fun name ->
      let pat = Ast_helper.Pat.variant name None in
      let expr = Ast_helper.Exp.constant (Const.string name) in
      Ast_helper.Exp.case pat expr
    ) constructor_names
  in

  let to_string_fun =
    Ast_helper.Exp.function_ to_string_cases
  in

  let to_string_val =
    Ast_helper.Vb.mk
      (Ast_helper.Pat.var {txt = "to_string"; loc})
      to_string_fun
  in

  (* 生成 of_string 函数 *)
  let of_string_cases =
    List.map (fun name ->
      let pat = Ast_helper.Pat.constant (Const.string name) in
      let expr = Ast_helper.Exp.variant name None in
      Ast_helper.Exp.case pat expr
    ) constructor_names @
    [Ast_helper.Exp.case
       (Ast_helper.Pat.var {txt = "_"; loc})
       [%expr failwith ("Unknown constructor: " ^ _s)]]
  in

  let of_string_fun =
    Ast_helper.Exp.function_ of_string_cases
  in

  let of_string_val =
    Ast_helper.Vb.mk
      (Ast_helper.Pat.var {txt = "of_string"; loc})
      of_string_fun
  in

  [Ast_helper.Str.value Nonrecursive [to_string_val; of_string_val]]

(** 处理记录类型 *)
let generate_helpers_for_record ~loc type_name fields =
  (* 生成字段访问函数 *)
  let field_accessors = List.map (fun (field : Parsetree.label_declaration) ->
    let field_name = field.pld_name.txt in
    let getter_name = "get_" ^ field_name in
    let getter_pat = Ast_helper.Pat.var {txt = getter_name; loc} in
    let getter_expr = [%expr fun r -> r.[%e Ast_helper.Exp.ident {txt = Longident.Lident field_name; loc}]] in
    Ast_helper.Vb.mk getter_pat getter_expr
  ) fields in

  [Ast_helper.Str.value Nonrecursive field_accessors]

(** ==================== 扩展注册 ==================== *)

(** 注册 %%auto 扩展
    语法：[%%auto type_definitions]

    这个扩展会为类型定义自动生成辅助函数
*)

let auto_extension =
  Extension.declare
    "auto"                           (* 扩展的名字 *)
    Extension.Context.structure_item (* 扩展的上下文：结构项 *)
    Ast_pattern.(pstr __)           (* 匹配结构项列表 *)
    (fun ~loc ~path:_ structure_items ->
       (* 处理每个结构项 *)
       List.concat_map (fun item ->
         match item.pstr_desc with
         | Pstr_type (_, type_decls) ->
             (* 为每个类型定义生成辅助函数 *)
             List.concat_map (fun (type_decl : Parsetree.type_declaration) ->
               match type_decl.ptype_kind with
               | Ptype_variant constructors ->
                   generate_helpers_for_variant ~loc type_decl.ptype_name.txt constructors
               | Ptype_record fields ->
                   generate_helpers_for_record ~loc type_decl.ptype_name.txt fields
               | _ -> []
             ) type_decls @ [item]  (* 保留原始类型定义 *)
         | _ -> [item]  (* 保留其他结构项 *)
       ) structure_items
    )

(** 注册重写器 *)
let () = Driver.register_transformation "auto" ~extensions:[auto_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    (* 定义类型并自动生成辅助函数 *)
    [%%auto {
      type color = Red | Green | Blue
      type person = { name : string; age : int }
    }]

    (* 编译后会自动生成：
       let to_string = function Red -> "Red" | Green -> "Green" | Blue -> "Blue"
       let of_string = function "Red" -> Red | "Green" -> Green | "Blue" -> Blue | _ -> failwith "..."
       let get_name r = r.name
       let get_age r = r.age
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 %%auto 扩展演示了：

    1. 如何处理结构项级别的扩展
    2. 如何分析类型定义的 AST
    3. 如何生成新的代码结构
    4. 如何同时保留原始代码和添加新代码
    5. 如何为不同类型的类型定义生成不同的辅助函数

    这展示了 PPX 在代码生成方面的强大能力
*)
