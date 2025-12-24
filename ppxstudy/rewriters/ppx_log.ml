(** 自定义 PPX 重写器：%log 扩展
    演示如何创建日志记录扩展

    这个扩展允许在表达式执行时自动记录日志
*)

open Ppxlib

(** ==================== 扩展注册 ==================== *)

(** 注册 %log 扩展
    语法：[%log expression]

    这个扩展会在表达式执行前记录日志，然后返回表达式的值
*)

let log_extension =
  Extension.declare
    "log"                             (* 扩展的名字 *)
    Extension.Context.expression      (* 扩展的上下文：表达式 *)
    Ast_pattern.(single_expr_payload __)  (* 匹配单个表达式 *)
    (fun ~loc ~path:_ expr ->
       (* 创建日志记录代码 *)
       let location_str = [%expr __FILE__ ^ ":" ^ string_of_int __LINE__] in
       let log_call = [%expr
         Printf.printf "[LOG] Executing expression at %s\n" [%e location_str]
       ] in

       (* 创建执行表达式的代码 *)
       let result_expr = [%expr
         let result = [%e expr] in
         Printf.printf "[LOG] Expression result: %s\n"
           (match result with
            | v -> try Printexc.to_string (Obj.magic v) with _ -> "<value>");
         result
       ] in

       (* 组合：先记录日志，再执行表达式 *)
       [%expr
         [%e log_call];
         [%e result_expr]
       ]
    )

(** 注册重写器 *)
let () = Driver.register_transformation "log" ~extensions:[log_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    (* 记录函数调用的日志 *)
    let result = [%log compute_expensive_value ()]

    (* 记录变量赋值的日志 *)
    let data = [%log load_data_from_file "input.txt"]

    (* 编译后会自动在表达式执行时打印日志信息 *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 %log 扩展演示了：

    1. 如何创建执行时日志记录
    2. 如何在表达式执行前插入代码
    3. 如何访问源码位置信息
    4. 如何处理表达式的返回值

    这在调试和监控程序执行时很有用
*)
