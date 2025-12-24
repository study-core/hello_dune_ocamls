(** 自定义 PPX 重写器：@@@timed 扩展
    演示如何为模块添加性能计时功能

    这个扩展会为模块中的所有函数添加执行时间测量
*)

open Ppxlib

(** ==================== 辅助函数 ==================== *)

(** 生成时间测量代码 *)
let create_timing_wrapper ~loc function_name function_expr =
  (* 创建时间测量变量 *)
  let start_time = Ast_helper.Pat.var {txt = "_start_time"; loc} in
  let start_binding = Ast_helper.Vb.mk start_time [%expr Unix.gettimeofday ()] in

  (* 创建函数调用 *)
  let call_expr = match function_expr.pexp_desc with
    | Pexp_fun (label, default, pat, body) ->
        (* 对于函数定义，我们需要包装函数体 *)
        let timed_body = [%expr
          let _start = Unix.gettimeofday () in
          try
            let result = [%e body] in
            let _elapsed = Unix.gettimeofday () -. _start in
            Printf.printf "[TIME] %s took %.6f seconds\n" [%e Ast_helper.Exp.constant (Const.string function_name)] _elapsed;
            result
          with e ->
            let _elapsed = Unix.gettimeofday () -. _start in
            Printf.printf "[TIME] %s failed after %.6f seconds\n" [%e Ast_helper.Exp.constant (Const.string function_name)] _elapsed;
            raise e
        ] in
        Ast_helper.Exp.fun_ label default pat timed_body
    | _ ->
        (* 对于其他表达式，直接包装 *)
        [%expr
          let _start = Unix.gettimeofday () in
          let result = [%e function_expr] in
          let _elapsed = Unix.gettimeofday () -. _start in
          Printf.printf "[TIME] %s took %.6f seconds\n" [%e Ast_helper.Exp.constant (Const.string function_name)] _elapsed;
          result
        ]
  in

  Ast_helper.Str.value Nonrecursive [Ast_helper.Vb.mk (Ast_helper.Pat.var {txt = function_name; loc}) call_expr]

(** ==================== 扩展注册 ==================== *)

(** 注册 @@@timed 扩展
    语法：module M @@@ timed = struct ... end

    这个扩展会为模块中的所有函数添加计时功能

    生成的代码示例：
    输入：  module Math @@@ timed = struct
             let fibonacci n = if n <= 1 then n else fibonacci (n - 1) + fibonacci (n - 2)
           end

    输出：  module Math = struct
             let fibonacci n =
               let _start = Unix.gettimeofday () in
               let result = if n <= 1 then n else fibonacci (n - 1) + fibonacci (n - 2) in
               let _elapsed = Unix.gettimeofday () -. _start in
               Printf.printf "[TIME] fibonacci took %.6f seconds\n" _elapsed;
               result
           end
*)

let timed_extension =
  Extension.declare
    "timed"                         (* 扩展的名字 *)
    Extension.Context.module_expr   (* 扩展的上下文：模块表达式 *)
    Ast_pattern.(__)               (* 匹配任意模块表达式 *)
    (fun ~loc ~path:_ module_expr ->
       (* 处理模块表达式 *)
       match module_expr.pmod_desc with
       | Pmod_structure structure_items ->
           (* 遍历所有结构项，为函数添加计时 *)
           let timed_items = List.map (fun item ->
             match item.pstr_desc with
             | Pstr_value (rec_flag, value_bindings) ->
                 (* 处理值绑定（包括函数定义） *)
                 let timed_bindings = List.map (fun (vb : Parsetree.value_binding) ->
                   match vb.pvb_pat.ppat_desc with
                   | Ppat_var {txt = function_name; _} ->
                       (* 为函数添加计时包装 *)
                       create_timing_wrapper ~loc function_name vb.pvb_expr
                   | _ ->
                       (* 非函数定义，保持不变 *)
                       Ast_helper.Str.value rec_flag [vb]
                 ) value_bindings in
                 (* 合并所有绑定 *)
                 List.concat timed_bindings
             | _ ->
                 (* 其他结构项保持不变 *)
                 [item]
           ) structure_items in

           (* 返回修改后的模块 *)
           Ast_helper.Mod.structure (List.concat timed_items)
       | _ ->
           (* 对于非结构模块，返回原样 *)
           module_expr
    )

(** 注册重写器 *)
let () = Driver.register_transformation "timed" ~extensions:[timed_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    module Calculator @@@ timed = struct
      let add x y = x + y
      let multiply x y = x * y
      let factorial n =
        let rec aux acc = function 0 -> acc | m -> aux (acc * m) (m - 1) in
        aux 1 n
    end

    (* 调用时会自动显示执行时间：
       let result = Calculator.add 5 3
       (* 输出: [TIME] add took 0.000001 seconds *)
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 @@@timed 扩展演示了：

    1. 如何为模块添加横切关注点（AOP）
    2. 如何修改函数定义以添加额外的行为
    3. 如何处理递归函数和复杂表达式
    4. 如何在运行时收集性能指标

    这在性能监控和调试中非常有用
*)
