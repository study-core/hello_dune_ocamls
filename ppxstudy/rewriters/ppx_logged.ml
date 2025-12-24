(** 自定义 PPX 重写器：@@@logged 扩展
    演示如何为模块添加自动日志记录功能

    这个扩展会为模块中的所有函数调用添加日志记录
*)

open Ppxlib

(** ==================== 辅助函数 ==================== *)

(** 生成带日志的函数包装 *)
let create_logged_wrapper ~loc function_name function_expr =
  match function_expr.pexp_desc with
  | Pexp_fun (label, default, pat, body) ->
      (* 对于函数定义，包装函数体以记录调用和返回 *)
      let logged_body = [%expr
        Printf.printf "[LOG] %s called\n" [%e Ast_helper.Exp.constant (Const.string function_name)];
        try
          let result = [%e body] in
          Printf.printf "[LOG] %s returned\n" [%e Ast_helper.Exp.constant (Const.string function_name)];
          result
        with e ->
          Printf.printf "[LOG] %s raised exception\n" [%e Ast_helper.Exp.constant (Const.string function_name)];
          raise e
      ] in
      Ast_helper.Str.value Nonrecursive [
        Ast_helper.Vb.mk
          (Ast_helper.Pat.var {txt = function_name; loc})
          (Ast_helper.Exp.fun_ label default pat logged_body)
      ]
  | _ ->
      (* 对于其他表达式，直接包装 *)
      Ast_helper.Str.value Nonrecursive [
        Ast_helper.Vb.mk
          (Ast_helper.Pat.var {txt = function_name; loc})
          [%expr
            Printf.printf "[LOG] %s executed\n" [%e Ast_helper.Exp.constant (Const.string function_name)];
            [%e function_expr]
          ]
      ]

(** ==================== 扩展注册 ==================== *)

(** 注册 @@@logged 扩展
    语法：module M @@@ logged = struct ... end

    这个扩展会为模块中的所有函数添加日志记录

    生成的代码示例：
    输入：  module Database @@@ logged = struct
             let connect host port = (* connection code *)
           end

    输出：  module Database = struct
             let connect host port =
               Printf.printf "[LOG] connect called\n";
               let result = (* connection code *) in
               Printf.printf "[LOG] connect returned\n";
               result
           end
*)

let logged_extension =
  Extension.declare
    "logged"                       (* 扩展的名字 *)
    Extension.Context.module_expr  (* 扩展的上下文：模块表达式 *)
    Ast_pattern.(__)              (* 匹配任意模块表达式 *)
    (fun ~loc ~path:_ module_expr ->
       (* 处理模块表达式 *)
       match module_expr.pmod_desc with
       | Pmod_structure structure_items ->
           (* 遍历所有结构项，为函数添加日志 *)
           let logged_items = List.map (fun item ->
             match item.pstr_desc with
             | Pstr_value (rec_flag, value_bindings) ->
                 (* 处理值绑定（包括函数定义） *)
                 let logged_bindings = List.map (fun (vb : Parsetree.value_binding) ->
                   match vb.pvb_pat.ppat_desc with
                   | Ppat_var {txt = function_name; _} ->
                       (* 为函数添加日志包装 *)
                       create_logged_wrapper ~loc function_name vb.pvb_expr
                   | _ ->
                       (* 非函数定义，保持不变 *)
                       Ast_helper.Str.value rec_flag [vb]
                 ) value_bindings in
                 (* 合并所有绑定 *)
                 List.concat logged_bindings
             | _ ->
                 (* 其他结构项保持不变 *)
                 [item]
           ) structure_items in

           (* 返回修改后的模块 *)
           Ast_helper.Mod.structure (List.concat logged_items)
       | _ ->
           (* 对于非结构模块，返回原样 *)
           module_expr
    )

(** 注册重写器 *)
let () = Driver.register_transformation "logged" ~extensions:[logged_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    module Database @@@ logged = struct
      let connect host port =
        (* 连接数据库的代码 *)
        Printf.printf "Connected to %s:%d\n" host port

      let query sql =
        (* 执行查询的代码 *)
        Printf.printf "Executing: %s\n" sql;
        ["result1"; "result2"]

      let disconnect () =
        (* 断开连接的代码 *)
        print_endline "Disconnected"
    end

    (* 调用时会自动记录日志：
       Database.connect "localhost" 5432
       (* 输出:
          [LOG] connect called
          Connected to localhost:5432
          [LOG] connect returned
       *)
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 @@@logged 扩展演示了：

    1. 如何为模块添加调用日志记录
    2. 如何处理函数的调用和返回
    3. 如何处理异常情况
    4. 如何在模块级别实现 AOP

    这在调试和监控应用程序行为时非常有用
*)
