(** 自定义 PPX 重写器：@@@cached 扩展
    演示如何为模块添加自动缓存功能

    这个扩展会为模块中的纯函数添加结果缓存
*)

open Ppxlib

(** ==================== 辅助函数 ==================== *)

(** 生成带缓存的函数包装 *)
let create_cached_wrapper ~loc function_name function_expr cache_name =
  match function_expr.pexp_desc with
  | Pexp_fun (label, default, pat, body) ->
      (* 分析函数参数 *)
      let param_patterns = match pat.ppat_desc with
        | Ppat_var {txt = param_name; _} ->
            (* 单参数函数 *)
            [Ast_helper.Pat.var {txt = param_name; loc}]
        | Ppat_tuple patterns ->
            (* 多参数函数 - 暂时简化处理 *)
            patterns
        | _ ->
            (* 其他参数模式 - 暂时不支持 *)
            []

      (* 创建缓存查找和存储逻辑 *)
      let cached_body = [%expr
        let cache = [%e Ast_helper.Exp.ident {txt = Longident.parse cache_name; loc}] in
        let key = ([%e pat], ()) in  (* 简化的键生成 *)
        try
          Printf.printf "[CACHE] Cache hit for %s\n" [%e Ast_helper.Exp.constant (Const.string function_name)];
          Hashtbl.find cache key
        with Not_found ->
          Printf.printf "[CACHE] Cache miss for %s, computing...\n" [%e Ast_helper.Exp.constant (Const.string function_name)];
          let result = [%e body] in
          Hashtbl.add cache key result;
          result
      ] in

      (* 创建缓存表 *)
      let cache_binding = Ast_helper.Str.value Nonrecursive [
        Ast_helper.Vb.mk
          (Ast_helper.Pat.var {txt = cache_name; loc})
          [%expr Hashtbl.create 16]
      ] in

      (* 创建缓存版本的函数 *)
      let cached_function = Ast_helper.Str.value Nonrecursive [
        Ast_helper.Vb.mk
          (Ast_helper.Pat.var {txt = function_name; loc})
          (Ast_helper.Exp.fun_ label default pat cached_body)
      ] in

      [cache_binding; cached_function]
  | _ ->
      (* 非函数定义，保持不变 *)
      [Ast_helper.Str.value Nonrecursive [
        Ast_helper.Vb.mk
          (Ast_helper.Pat.var {txt = function_name; loc})
          function_expr
      ]]

(** ==================== 扩展注册 ==================== *)

(** 注册 @@@cached 扩展
    语法：module M @@@ cached = struct ... end

    这个扩展会为模块中的函数添加缓存功能

    生成的代码示例：
    输入：  module Computation @@@ cached = struct
             let expensive_calc x = x * x
           end

    输出：  module Computation = struct
             let expensive_calc_cache = Hashtbl.create 16
             let expensive_calc x =
               try Hashtbl.find expensive_calc_cache x
               with Not_found ->
                 let result = x * x in
                 Hashtbl.add expensive_calc_cache x result;
                 result
           end
*)

let cached_extension =
  Extension.declare
    "cached"                       (* 扩展的名字 *)
    Extension.Context.module_expr  (* 扩展的上下文：模块表达式 *)
    Ast_pattern.(__)              (* 匹配任意模块表达式 *)
    (fun ~loc ~path:_ module_expr ->
       (* 处理模块表达式 *)
       match module_expr.pmod_desc with
       | Pmod_structure structure_items ->
           (* 遍历所有结构项，为函数添加缓存 *)
           let cached_items = List.concat_map (fun item ->
             match item.pstr_desc with
             | Pstr_value (rec_flag, value_bindings) ->
                 (* 处理值绑定（包括函数定义） *)
                 List.concat_map (fun (vb : Parsetree.value_binding) ->
                   match vb.pvb_pat.ppat_desc with
                   | Ppat_var {txt = function_name; _} ->
                       (* 为函数添加缓存包装 *)
                       let cache_name = function_name ^ "_cache" in
                       create_cached_wrapper ~loc function_name vb.pvb_expr cache_name
                   | _ ->
                       (* 非函数定义，保持不变 *)
                       [Ast_helper.Str.value rec_flag [vb]]
                 ) value_bindings
             | _ ->
                 (* 其他结构项保持不变 *)
                 [item]
           ) structure_items in

           (* 返回修改后的模块 *)
           Ast_helper.Mod.structure cached_items
       | _ ->
           (* 对于非结构模块，返回原样 *)
           module_expr
    )

(** 注册重写器 *)
let () = Driver.register_transformation "cached" ~extensions:[cached_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    module Math @@@ cached = struct
      let rec fibonacci n =
        if n <= 1 then n
        else fibonacci (n - 1) + fibonacci (n - 2)

      let expensive_computation x =
        (* 模拟耗时的计算 *)
        Unix.sleepf 0.1;
        x * x
    end

    (* 第一次调用会被缓存：
       let result1 = Math.fibonacci 10  (* 计算并缓存 *)
       let result2 = Math.expensive_computation 5  (* 计算并缓存 *)

       第二次调用直接从缓存返回：
       let result3 = Math.fibonacci 10  (* 从缓存返回 *)
       let result4 = Math.expensive_computation 5  (* 从缓存返回 *)
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个 @@@cached 扩展演示了：

    1. 如何为模块添加自动缓存功能
    2. 如何处理函数的结果缓存
    3. 如何优化重复计算的性能
    4. 如何在模块级别实现缓存策略

    注意：这个实现是简化的，实际的缓存应该考虑：
    - 缓存大小限制
    - 缓存失效策略
    - 并发安全性
    - 参数的哈希计算
*)
