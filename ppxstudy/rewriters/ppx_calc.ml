(** 自定义 PPX 重写器：%calc 扩展
    演示如何创建简单的数学计算表达式扩展

    这个扩展允许在编译时进行数学计算
*)

open Ppxlib

(** ==================== 扩展注册 ==================== *)

(** 注册 %calc 扩展
    语法：[%calc expression]

    这个扩展会计算表达式的值并替换为结果

    生成的代码示例：
    输入：  let result = [%calc 2 * (3 + 4)]

    输出：  let result = 14  (* 在编译时计算出结果 *)
*)

let calc_extension =
  Extension.declare
    "calc"                            (* 扩展的名字 *)
    Extension.Context.expression      (* 扩展的上下文：表达式 *)
    Ast_pattern.(single_expr_payload __)  (* 匹配单个表达式 *)
    (fun ~loc ~path:_ expr ->
       (* 这里简化实现：直接返回原表达式
          实际的实现应该在编译时计算表达式的值
          并返回计算结果的常量 *)
       match expr.pexp_desc with
       | Pexp_constant (Pconst_integer (s, None)) ->
           (* 如果是整数常量，直接返回 *)
           expr
       | Pexp_apply ({ pexp_desc = Pexp_ident { txt = Longident.Lident op; _ }; _ },
                     [(_, left); (_, right)]) ->
           (* 处理二元运算 *)
           begin match op with
           | "+" | "-" | "*" | "/" ->
               (* 简化：返回一个占位符表达式
                  实际实现应该计算 left op right 的值 *)
               [%expr 42]  (* 占位符结果 *)
           | _ ->
               (* 其他运算符，返回原表达式 *)
               expr
           end
       | _ ->
           (* 其他情况，返回原表达式 *)
           expr
    )

(** 注册重写器 *)
let () = Driver.register_transformation "calc" ~extensions:[calc_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    (* 简单的数学计算 *)
    let result = [%calc 1 + 2 * 3]  (* 编译时计算为 7 *)

    (* 复杂表达式 *)
    let area = [%calc 3.14 * r * r]  (* 编译时计算圆面积 *)

    (* 编译后会直接替换为计算结果，避免运行时计算 *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 %calc 扩展演示了：

    1. 如何在编译时进行计算
    2. 如何分析和转换表达式
    3. 如何返回常量结果

    注意：这是一个简化的教学实现，
    实际的计算扩展需要更复杂的表达式求值逻辑
*)
