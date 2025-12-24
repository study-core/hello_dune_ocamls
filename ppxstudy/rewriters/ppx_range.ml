(** 自定义 PPX 重写器：@range 扩展
    演示如何实现范围匹配的模式扩展

    这个扩展允许在模式匹配中使用数值范围检查
*)

open Ppxlib

(** ==================== 扩展注册 ==================== *)

(** 注册 @range 扩展
    语法：_ @range min max

    这个扩展会将范围匹配转换为 when 条件

    生成的代码示例：
    输入：  | _ @range 90 100 -> "A"
           | _ @range 80 90 -> "B"

    输出：  | _range_match when _range_match >= 90 && _range_match <= 100 -> "A"
           | _range_match when _range_match >= 80 && _range_match <= 90 -> "B"
*)

let range_extension =
  Extension.declare
    "range"                            (* 扩展的名字 *)
    Extension.Context.pattern          (* 扩展的上下文：模式 *)
    Ast_pattern.(pair __ __)          (* 匹配两个表达式参数：min 和 max *)
    (fun ~loc ~path:_ (min_expr, max_expr) ->
       (* 创建一个变量模式来绑定匹配的值 *)
       let var_pat = Ast_helper.Pat.var {txt = "_range_match"; loc} in

       (* 创建 when 条件：检查值是否在范围内 *)
       let when_expr = [%expr
         _range_match >= [%e min_expr] && _range_match <= [%e max_expr]
       ] in

       (* 返回带条件的模式 *)
       Ast_helper.Pat.when_ var_pat when_expr
    )

(** 注册重写器 *)
let () = Driver.register_transformation "range" ~extensions:[range_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    let grade_score score =
      match score with
      | _ @range 90 100 -> "优秀"    (* 90-100分 *)
      | _ @range 80 90 -> "良好"     (* 80-89分 *)
      | _ @range 70 80 -> "中等"     (* 70-79分 *)
      | _ @range 60 70 -> "及格"     (* 60-69分 *)
      | _ -> "不及格"

    (* 编译后会转换为：
       let grade_score score =
         match score with
         | _range_match when _range_match >= 90 && _range_match <= 100 -> "优秀"
         | _range_match when _range_match >= 80 && _range_match <= 90 -> "良好"
         | _range_match when _range_match >= 70 && _range_match <= 80 -> "中等"
         | _range_match when _range_match >= 60 && _range_match <= 70 -> "及格"
         | _ -> "不及格"
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 @range 扩展演示了：

    1. 如何处理多参数的模式扩展
    2. 如何使用 Ast_pattern.(pair __ __) 匹配参数对
    3. 如何生成数值范围检查的 when 条件
    4. 如何在模式匹配中集成范围验证

    这在分数分级、年龄验证等场景中很有用
*)
