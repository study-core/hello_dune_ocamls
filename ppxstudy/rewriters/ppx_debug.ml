(** 自定义 PPX 重写器：%debug 扩展
    演示如何创建简单的表达式级别 PPX 扩展

    这个扩展会在表达式执行时打印调试信息
*)

open Ppxlib

(** ==================== 扩展注册 ==================== *)

(** 注册 %debug 扩展
    语法：[%debug expression]

    这个扩展会：
    1. 打印表达式的源码
    2. 执行表达式
    3. 打印表达式的结果
    4. 返回结果
*)

let debug_extension =
  Extension.declare
    "debug"                          (* 扩展的名字 *)
    Extension.Context.expression     (* 扩展的上下文：表达式 *)
    Ast_pattern.(single_expr_payload __)  (* 匹配单个表达式 *)
    (fun ~loc ~path:_ expr ->        (* 处理函数 *)
       (* 创建调试信息 *)
       let debug_str = Ppxlib_ast.Ast_helper.Exp.constant
         (Ppxlib_ast.Ast_helper.Const.string (Ppxlib_ast.Pprintast.string_of_expression expr)) in

       (* 创建打印表达式的代码 *)
       let print_expr = [%expr Printf.printf "🐛 [DEBUG] 表达式: %s\n" [%e debug_str]] in

       (* 创建执行并打印结果的代码 *)
       let result_expr = [%expr
         let result = [%e expr] in
         Printf.printf "🐛 [DEBUG] 结果: %s\n"
           (match result with
            | v -> Printexc.to_string (Obj.magic v));  (* 简单的值打印 *)
         result
       ] in

       (* 组合最终的表达式 *)
       [%expr
         [%e print_expr];
         [%e result_expr]
       ]
    )

(** 注册重写器 *)
let () = Driver.register_transformation "debug" ~extensions:[debug_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    (* 启用调试模式 *)
    [%%ifdef DEBUG then
      let debug_enabled = true
    else
      let debug_enabled = false
    end]

    (* 使用 %debug 扩展 *)
    let x = [%debug 1 + 2 + 3]
    let y = [%debug String.length "hello"]
    let z = [%debug List.map (fun x -> x * 2) [1; 2; 3]]

    (* 编译时会转换为类似这样的代码：
       let x =
         Printf.printf "🐛 [DEBUG] 表达式: 1 + 2 + 3\n";
         let result = 1 + 2 + 3 in
         Printf.printf "🐛 [DEBUG] 结果: 6\n";
         result
    *)

*)

(** ==================== 编译和使用 ==================== *)

(** 1. 编译这个重写器：
    dune build ppxstudy/rewriters

    2. 使用重写器编译其他文件：
    ocamlc -ppx './ppx_study_rewriters.exe' your_file.ml

    3. 或者在 dune 中配置：
    (preprocess (pps ppx_study_rewriters))

*)

(** ==================== 扩展说明 ==================== *)

(** 这个简单的 %debug 扩展演示了：

    1. 如何使用 Extension.declare 注册扩展
    2. 如何指定扩展上下文（expression）
    3. 如何使用 Ast_pattern 匹配语法
    4. 如何使用 Ast_helper 构造新的 AST
    5. 如何使用 metaquot ([%expr ...]) 创建代码模板
    6. 如何注册转换器

    这为学习更复杂的 PPX 扩展提供了基础
*)
