(** 自定义 PPX 重写器：@valid 扩展
    演示如何实现条件验证的模式扩展

    这个扩展允许在模式匹配中添加额外的验证条件
*)

open Ppxlib

(** ==================== 扩展注册 ==================== *)

(** 注册 @valid 扩展
    语法：pattern @valid condition_expression

    这个扩展会将额外的验证条件添加到模式中

    生成的代码示例：
    输入：  | {name; age; email} @valid (age >= 18 && String.contains email '@') -> true

    输出：  | {name; age; email} when (age >= 18 && String.contains email '@') -> true
*)

let valid_extension =
  Extension.declare
    "valid"                           (* 扩展的名字 *)
    Extension.Context.pattern         (* 扩展的上下文：模式 *)
    Ast_pattern.(single_expr_payload __)  (* 匹配单个表达式参数：验证条件 *)
    (fun ~loc ~path:_ condition_expr ->
       (* 创建一个变量模式来绑定匹配的值 *)
       let var_pat = Ast_helper.Pat.var {txt = "_valid_match"; loc} in

       (* 创建 when 条件：执行验证条件
          注意：这里假设 condition_expr 中使用了 _valid_match 变量 *)
       let when_expr = condition_expr in

       (* 返回带条件的模式 *)
       Ast_helper.Pat.when_ var_pat when_expr
    )

(** 注册重写器 *)
let () = Driver.register_transformation "valid" ~extensions:[valid_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    type user = { name : string; age : int; email : string }

    let validate_user user =
      match user with
      | {name; age; email} @valid (String.length name > 0 &&
                                   age >= 18 && age <= 120 &&
                                   String.contains email '@') -> true
      | _ -> false

    (* 编译后会转换为：
       let validate_user user =
         match user with
         | {name; age; email} when (String.length name > 0 &&
                                    age >= 18 && age <= 120 &&
                                    String.contains email '@') -> true
         | _ -> false
    *)

    (* 更复杂的验证示例：
       let check_number n =
         match n with
         | _ @valid (n > 0 && n mod 2 = 0) -> "正偶数"
         | _ @valid (n > 0 && n mod 2 = 1) -> "正奇数"
         | _ @valid (n < 0) -> "负数"
         | _ -> "零"
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 @valid 扩展演示了：

    1. 如何将表达式作为参数传递给模式扩展
    2. 如何在模式匹配中集成复杂的验证逻辑
    3. 如何扩展基本的模式匹配能力
    4. 如何处理条件验证的通用模式

    这在数据验证、业务规则检查等场景中很有用
*)
