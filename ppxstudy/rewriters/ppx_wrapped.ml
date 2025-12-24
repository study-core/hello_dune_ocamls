(** 自定义 PPX 重写器：@@@wrapped 扩展
    演示如何创建模块级别的 PPX 扩展

    这个扩展为模块添加包装功能
*)

open Ppxlib

(** ==================== 扩展注册 ==================== *)

(** 注册 @@@wrapped 扩展
    语法：module M @@@ wrapped = struct ... end

    这个扩展会为模块添加包装结构
*)

let wrapped_extension =
  Extension.declare
    "wrapped"                       (* 扩展的名字 *)
    Extension.Context.module_expr   (* 扩展的上下文：模块表达式 *)
    Ast_pattern.(__)               (* 匹配任意模块表达式 *)
    (fun ~loc ~path:_ module_expr ->
       (* 处理模块表达式 *)
       match module_expr.pmod_desc with
       | Pmod_structure structure_items ->
           (* 为模块添加包装结构 *)
           let wrapper_items = [
             (* 添加包装标识 *)
             Ast_helper.Str.value Nonrecursive [
               Ast_helper.Vb.mk
                 (Ast_helper.Pat.var {txt = "__wrapped_module"; loc})
                 (Ast_helper.Exp.constant (Const.string "wrapped"))
             ]
           ] @ structure_items in

           (* 返回包装后的模块 *)
           Ast_helper.Mod.structure wrapper_items
       | _ ->
           (* 对于非结构模块，返回原样 *)
           module_expr
    )

(** 注册重写器 *)
let () = Driver.register_transformation "wrapped" ~extensions:[wrapped_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    module Logger @@@ wrapped = struct
      let log level msg = Printf.printf "[%s] %s\n" level msg
      let debug msg = log "DEBUG" msg
      let info msg = log "INFO" msg
      let error msg = log "ERROR" msg
    end

    (* 编译后会转换为：
       module Logger = struct
         let __wrapped_module = "wrapped"
         let log level msg = Printf.printf "[%s] %s\n" level msg
         let debug msg = log "DEBUG" msg
         let info msg = log "INFO" msg
         let error msg = log "ERROR" msg
       end
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 @@@wrapped 扩展演示了：

    1. 如何创建模块级别的扩展
    2. 如何修改模块的内部结构
    3. 如何添加新的定义到模块中
    4. 如何保持模块的其他功能不变

    模块级别的扩展可以实现 AOP（面向切面编程）的概念
*)

(** ==================== 可能的扩展 ==================== *)

(** @@@wrapped 可以扩展为实现：

    1. 性能监控：
       module M @@@ timed = struct ... end

    2. 日志记录：
       module M @@@ logged = struct ... end

    3. 缓存：
       module M @@@ cached = struct ... end

    4. 安全检查：
       module M @@@ secured = struct ... end

    这些都是模块级别扩展的常见应用场景
*)
