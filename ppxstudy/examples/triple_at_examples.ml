(** @@@ 扩展示例 - 模块级别的扩展点 *)

(** 状态：历史属性与手写模拟合集。@@@ 表示浮动属性，不等于模块扩展；
    自定义块也不匹配当前 module_expr rewriters。详见同目录 README.md。 *)

(** ===============================================
    @@@ 扩展语法示例

    OCaml 官方内置了很多 @@@ 扩展！
    这里展示官方的 @@@ 扩展用法
    ===============================================
*)

(** 🏛️ 官方内置的 @@@ 扩展 *)

(** 1. @@@warning - 警告控制 *)
[@@@warning "+9"]  (* 在整个文件中启用警告9 *)

module WarningExample = struct
  [@@@warning "-9"]  (* 在这个结构中禁用警告9 *)

  let x = 42  (* 这里不会触发警告9 *)

  [@@@warning "+9"]  (* 重新启用警告9 *)
  let y = 42  (* 这里会触发警告9，如果适用的话 *)
end

(** 2. @@@deprecated - 弃用标记 *)
[@@@deprecated "This module will be removed in version 2.0"]

module DeprecatedModule = struct
  [@@@deprecated "Use new_function instead"]
  let old_function x = x + 1

  let new_function x = x + 1  (* 推荐使用的函数 *)
end

(** 3. @@@alert - 警报标记 *)
[@@@alert unsafe "This module contains unsafe operations"]

module UnsafeModule = struct
  [@@@alert "-unsafe"]  (* 在这个模块中禁用unsafe警报 *)

  external unsafe_operation : unit -> unit = "unsafe_c_function"
end

(** 4. @@@inline - 内联控制 *)
[@@@inline]  (* 强制内联这个模块中的函数 *)

module InlineModule = struct
  [@@@inline never]  (* 从不内联 *)
  let expensive_computation x = x * x

  [@@@inline always]  (* 总是内联 *)
  let simple_calculation x = x + 1
end

(** 5. @@@specialise - 特化控制 *)
[@@@specialise]  (* 允许特化这个模块中的函数 *)

module SpecialiseModule = struct
  [@@@specialise never]  (* 不允许特化 *)
  let generic_function x = x

  [@@@specialise always]  (* 总是特化 *)
  let specific_function (x : int) = x + 1
end

(** 6. @@@local - 本地分配控制 *)
[@@@local]  (* 允许本地分配 *)

module LocalModule = struct
  [@@@local never]  (* 不允许本地分配 *)
  let global_ref = ref 0

  [@@@local always]  (* 总是本地分配 *)
  let local_computation x = x * 2
end

(** 7. @@@tailcall - 尾调用优化控制 *)
module TailcallModule = struct
  [@@@tailcall true]  (* 启用尾调用优化 *)
  let rec sum n acc =
    if n = 0 then acc
    else sum (n - 1) (acc + n)

  [@@@tailcall false]  (* 禁用尾调用优化 *)
  let rec bad_sum n =
    if n = 0 then 0
    else n + bad_sum (n - 1)  (* 不是尾递归 *)
end

(** 8. @@@unbox - 装箱控制 *)
module UnboxModule = struct
  type boxed_int = int  (* 默认装箱 *)

  [@@@unboxed]  (* 取消装箱 *)
  type unboxed_int = int

  [@@@unbox]  (* 控制特定类型的装箱 *)
  type controlled = Boxed of int | Unboxed of (int [@unboxed])
end

(** 展开后代码（@@@unboxed）：
    (* @@@unboxed 影响编译器如何处理类型定义和值 *)
    (* 它改变的是运行时表示，而不是源码本身 *)
    (* unboxed_int 类型的值在运行时不进行装箱操作 *)
    (* 这会影响性能和内存使用，但语法保持不变 *)
*)

(** 9. @@@inline - 内联属性（函数级别） *)
module InlineFunctions = struct
  [@@@inline]  (* 强制内联 *)
  let always_inline x = x + 1

  [@@@inline never]  (* 从不内联 *)
  let never_inline x = print_endline "Computing..."; x * 2

  [@@@inline hint]  (* 建议内联 *)
  let hint_inline x = x + 10
end

(** 展开后代码（@@@inline）：
    (* @@@inline 影响编译器的代码生成 *)
    (* always_inline 函数会在调用点直接展开为 x + 1 *)
    (* never_inline 函数永远不会被内联 *)
    (* hint_inline 函数编译器会考虑内联，但不是强制 *)
*)

(** 10. @@@specialise - 特化属性（函数级别） *)
module SpecialiseFunctions = struct
  [@@@specialise]  (* 允许特化 *)
  let specialisable f x = f x

  [@@@specialise never]  (* 不允许特化 *)
  let not_specialisable f x = f x
end

(** 展开后代码（@@@specialise）：
    (* @@@specialise 影响多态函数的编译 *)
    (* specialisable 可能会为特定类型生成特化版本 *)
    (* not_specialisable 保持泛型实现 *)
    (* 这影响的是编译后的机器码，不是源码 *)
*)

(** 9. @@@inline - 内联属性（函数级别） *)
module InlineFunctions = struct
  [@@@inline]  (* 强制内联 *)
  let always_inline x = x + 1

  [@@@inline never]  (* 从不内联 *)
  let never_inline x = print_endline "Computing..."; x * 2

  [@@@inline hint]  (* 建议内联 *)
  let hint_inline x = x + 10
end

(** 10. @@@specialise - 特化属性（函数级别） *)
module SpecialiseFunctions = struct
  [@@@specialise]  (* 允许特化 *)
  let specialisable f x = f x

  [@@@specialise never]  (* 不允许特化 *)
  let not_specialisable f x = f x
end

(** ===============================================
    自定义 @@@ 扩展语法示例（需要重写器实现）
    ===============================================
*)

(** 基本的模块包装扩展 (@wrapped) - 自定义 *)
[@@@wrapped
module Calculator = struct
  let add x y = x + y
  let multiply x y = x * y
  let divide x y = if y = 0.0 then failwith "Division by zero" else x /. y
end]

(** 展开后代码（@@@wrapped）：
    module Calculator = struct
      let __wrapped_module = "wrapped"  (* 自动添加的标识 *)
      let add x y = x + y
      let multiply x y = x * y
      let divide x y = if y = 0.0 then failwith "Division by zero" else x /. y
    end
*)

(** 日志记录扩展 (@logged) - 自定义 *)
[@@@logged
module Logger = struct
  let log level msg = Printf.printf "[%s] %s\n" level msg
  let info msg = log "INFO" msg
  let debug msg = log "DEBUG" msg
  let error msg = log "ERROR" msg
end]

(** 展开后代码（@@@logged）：
    module Logger = struct
      let log level msg =
        Printf.printf "[LOG] log called\n";  (* 自动添加的调用日志 *)
        let result = Printf.printf "[%s] %s\n" level msg in
        Printf.printf "[LOG] log returned\n";  (* 自动添加的返回日志 *)
        result
      let info msg = log "INFO" msg  (* 同样会被包装 *)
      let debug msg = log "DEBUG" msg
      let error msg = log "ERROR" msg
    end
*)

(** 性能计时扩展 (@timed) - 自定义 *)
[@@@timed
module Math = struct
  let rec fibonacci n =
    if n <= 1 then n
    else fibonacci (n - 1) + fibonacci (n - 2)

  let factorial n =
    let rec aux acc = function 0 -> acc | m -> aux (acc * m) (m - 1) in
    aux 1 n
end]

(** 展开后代码（@@@timed）：
    module Math = struct
      let fibonacci n =
        let _start = Unix.gettimeofday () in  (* 自动添加的时间测量 *)
        let result = if n <= 1 then n else fibonacci (n - 1) + fibonacci (n - 2) in
        let _elapsed = Unix.gettimeofday () -. _start in
        Printf.printf "[TIME] fibonacci took %.6f seconds\n" _elapsed;  (* 自动添加的输出 *)
        result
      let factorial n =
        let _start = Unix.gettimeofday () in
        let rec aux acc = function 0 -> acc | m -> aux (acc * m) (m - 1) in
        let result = aux 1 n in
        let _elapsed = Unix.gettimeofday () -. _start in
        Printf.printf "[TIME] factorial took %.6f seconds\n" _elapsed;
        result
    end
*)

(** 缓存扩展 (@cached) - 自定义 *)
[@@@cached
module Computation = struct
  let expensive_calc x =
    (* 模拟耗时计算 *)
    Unix.sleepf 0.01;
    x * x

  let complex_function n =
    (* 模拟复杂计算 *)
    let rec loop acc = function 0 -> acc | m -> loop (acc + m) (m - 1) in
    loop 0 n
end]

(** 展开后代码（@@@cached）：
    module Computation = struct
      let expensive_calc_cache = Hashtbl.create 16  (* 自动添加的缓存表 *)
      let expensive_calc x =
        try
          Printf.printf "[CACHE] Cache hit for expensive_calc\n";  (* 缓存命中提示 *)
          Hashtbl.find expensive_calc_cache x
        with Not_found ->
          Printf.printf "[CACHE] Cache miss for expensive_calc, computing...\n";
          let result = (Unix.sleepf 0.01; x * x) in  (* 原始计算 *)
          Hashtbl.add expensive_calc_cache x result;  (* 存储到缓存 *)
          result

      let complex_function_cache = Hashtbl.create 16
      let complex_function n =
        let key = n in  (* 简化的键生成 *)
        try
          Printf.printf "[CACHE] Cache hit for complex_function\n";
          Hashtbl.find complex_function_cache key
        with Not_found ->
          Printf.printf "[CACHE] Cache miss for complex_function, computing...\n";
          let rec loop acc = function 0 -> acc | m -> loop (acc + m) (m - 1) in
          let result = loop 0 n in
          Hashtbl.add complex_function_cache key result;
          result
    end
*)

(** ===============================================
    如果 @@@ 扩展可用，以上代码会被转换为：

    module Calculator = struct
      let __wrapped_module = "wrapped"  (* @@@wrapped 添加的 *)
      let add x y = x + y
      let multiply x y = x * y
      let divide x y = if y = 0.0 then failwith "Division by zero" else x /. y
    end

    module Logger = struct
      let log level msg =                   (* @@@logged 包装的函数 *)
          Printf.printf "[LOG] log called\n";
          let result = Printf.printf "[%s] %s\n" level msg in
          Printf.printf "[LOG] log returned\n";
          result
      let info msg = log "INFO" msg
      let debug msg = log "DEBUG" msg
      let error msg = log "ERROR" msg
    end

    module Math = struct
      let fibonacci n =                    (* @@@timed 包装的函数 *)
          let _start = Unix.gettimeofday () in
          let result = (* 原始逻辑 *) in
          let _elapsed = Unix.gettimeofday () -. _start in
          Printf.printf "[TIME] fibonacci took %.6f seconds\n" _elapsed;
          result
      (* factorial 函数类似 *)
    end

    module Computation = struct
      let expensive_calc_cache = Hashtbl.create 16  (* @@@cached 添加的 *)
      let expensive_calc x =
          let cache = expensive_calc_cache in
          try Hashtbl.find cache x
          with Not_found ->
            let result = (* 原始逻辑 *) in
            Hashtbl.add cache x result;
            result
      (* complex_function 类似 *)
    end

    ===============================================
*)

(** 由于当前没有真正的 @@@ 扩展，这里提供等效的手动实现：*)
module ManualCalculator = struct
  let __wrapped_module = "wrapped"
  let add x y = x + y
  let multiply x y = x * y
  let divide x y = if y = 0.0 then failwith "Division by zero" else x /. y
end

module ManualLogger = struct
  let log level msg =
    Printf.printf "[LOG] log called\n";
    let result = Printf.printf "[%s] %s\n" level msg in
    Printf.printf "[LOG] log returned\n";
    result

  let info msg = log "INFO" msg
  let debug msg = log "DEBUG" msg
  let error msg = log "ERROR" msg
end

module ManualMath = struct
  let fibonacci n =
    let _start = Unix.gettimeofday () in
    let result = if n <= 1 then n else fibonacci (n - 1) + fibonacci (n - 2) in
    let _elapsed = Unix.gettimeofday () -. _start in
    Printf.printf "[TIME] fibonacci took %.6f seconds\n" _elapsed;
    result

  let factorial n =
    let _start = Unix.gettimeofday () in
    let rec aux acc = function 0 -> acc | m -> aux (acc * m) (m - 1) in
    let result = aux 1 n in
    let _elapsed = Unix.gettimeofday () -. _start in
    Printf.printf "[TIME] factorial took %.6f seconds\n" _elapsed;
    result
end

module ManualComputation = struct
  let expensive_calc_cache = Hashtbl.create 16
  let complex_function_cache = Hashtbl.create 16

  let expensive_calc x =
    try
      Printf.printf "[CACHE] Cache hit for expensive_calc\n";
      Hashtbl.find expensive_calc_cache x
    with Not_found ->
      Printf.printf "[CACHE] Cache miss for expensive_calc, computing...\n";
      Unix.sleepf 0.01;
      let result = x * x in
      Hashtbl.add expensive_calc_cache x result;
      result

  let complex_function n =
    let key = n in
    try
      Printf.printf "[CACHE] Cache hit for complex_function\n";
      Hashtbl.find complex_function_cache key
    with Not_found ->
      Printf.printf "[CACHE] Cache miss for complex_function, computing...\n";
      let rec loop acc = function 0 -> acc | m -> loop (acc + m) (m - 1) in
      let result = loop 0 n in
      Hashtbl.add complex_function_cache key result;
      result
end

(** 使用示例 *)
let () =
  print_endline "=== @@@ 扩展概念演示 ===";
  print_endline "";

  (* Calculator 使用 *)
  print_endline "1. Calculator (wrapped):";
  let calc1 = ManualCalculator.add 5 3 in
  let calc2 = ManualCalculator.multiply 4 7 in
  Printf.printf "   5 + 3 = %d\n" calc1;
  Printf.printf "   4 * 7 = %d\n" calc2;
  print_endline "";

  (* Logger 使用 *)
  print_endline "2. Logger (logged):";
  ManualLogger.info "Application starting";
  ManualLogger.debug "Debug message";
  print_endline "";

  (* Math 使用 *)
  print_endline "3. Math (timed):";
  let fib = ManualMath.fibonacci 5 in
  let fact = ManualMath.factorial 3 in
  Printf.printf "   fibonacci(5) = %d\n" fib;
  Printf.printf "   factorial(3) = %d\n" fact;
  print_endline "";

  (* Computation 使用 *)
  print_endline "4. Computation (cached):";
  let exp1 = ManualComputation.expensive_calc 5 in
  let exp2 = ManualComputation.expensive_calc 5 in  (* 应该从缓存返回 *)
  let comp1 = ManualComputation.complex_function 10 in
  let comp2 = ManualComputation.complex_function 10 in (* 应该从缓存返回 *)
  Printf.printf "   expensive_calc(5) = %d (first call)\n" exp1;
  Printf.printf "   expensive_calc(5) = %d (cached)\n" exp2;
  Printf.printf "   complex_function(10) = %d (first call)\n" comp1;
  Printf.printf "   complex_function(10) = %d (cached)\n" comp2;
  print_endline "";

  print_endline "=== 演示完成 ==="
