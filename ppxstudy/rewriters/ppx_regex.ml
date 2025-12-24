(** 自定义 PPX 重写器：@regex 扩展
    演示如何创建模式级别的 PPX 扩展

    这个扩展允许在模式匹配中使用正则表达式
*)

open Ppxlib

(** ==================== 扩展注册 ==================== *)

(** 注册 @regex 扩展
    语法：pattern @ regex "pattern"

    这个扩展会将正则表达式模式转换为 when 条件
*)

let regex_extension =
  Extension.declare
    "regex"                         (* 扩展的名字 *)
    Extension.Context.pattern       (* 扩展的上下文：模式 *)
    Ast_pattern.(single_expr_payload __)  (* 匹配单个表达式（正则表达式字符串） *)
    (fun ~loc ~path:_ regex_expr ->
       (* 创建一个变量模式来绑定匹配的字符串 *)
       let var_pat = Ast_helper.Pat.var {txt = "_regex_match"; loc} in

       (* 创建 when 条件：检查字符串是否匹配正则表达式 *)
       let when_expr = [%expr
         try
           let regexp = Str.regexp [%e regex_expr] in
           Str.string_match regexp _regex_match 0
         with _ -> false
       ] in

       (* 返回带条件的模式 *)
       Ast_helper.Pat.when_ var_pat when_expr
    )

(** 注册重写器 *)
let () = Driver.register_transformation "regex" ~extensions:[regex_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    let classify_string s =
      match s with
      | _ @ regex "^\\d+$" -> "纯数字"
      | _ @ regex "^[a-zA-Z]+$" -> "纯字母"
      | _ @ regex "^[a-zA-Z0-9]+$" -> "字母数字"
      | _ -> "其他"

    (* 编译后会转换为：
       let classify_string s =
         match s with
         | _regex_match when (try let regexp = Str.regexp "^\\d+$" in
                                 Str.string_match regexp _regex_match 0 with _ -> false) -> "纯数字"
         | _regex_match when (try let regexp = Str.regexp "^[a-zA-Z]+$" in
                                 Str.string_match regexp _regex_match 0 with _ -> false) -> "纯字母"
         | _regex_match when (try let regexp = Str.regexp "^[a-zA-Z0-9]+$" in
                                 Str.string_match regexp _regex_match 0 with _ -> false) -> "字母数字"
         | _ -> "其他"
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 @regex 扩展演示了：

    1. 如何创建模式级别的扩展
    2. 如何使用 Ast_helper.Pat.when_ 创建带条件的模式
    3. 如何在模式匹配中嵌入复杂的逻辑
    4. 如何处理正则表达式的编译时转换

    模式级别的扩展可以让模式匹配更加灵活和强大
*)
