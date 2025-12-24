(** @@@ 扩展示例 - 模块级别的实际用法 *)

(** 基本的模块定义 *)
module Calculator = struct
  let add x y = x + y
  let multiply x y = x * y
  let divide x y = if y = 0.0 then failwith "Division by zero" else x /. y
end

(** 日志模块 *)
module Logger = struct
  let log level msg = Printf.printf "[%s] %s\n" level msg
  let info msg = log "INFO" msg
  let debug msg = log "DEBUG" msg
  let error msg = log "ERROR" msg
end

(** 缓存模块示例 *)
module Cache = struct
  let cache = Hashtbl.create 16

  let get_or_compute key compute =
    try Hashtbl.find cache key
    with Not_found ->
      let result = compute () in
      Hashtbl.add cache key result;
      result
end

(** 数学模块 *)
module Math = struct
  let rec fibonacci n =
    if n <= 1 then n
    else fibonacci (n - 1) + fibonacci (n - 2)

  let factorial n =
    let rec aux acc = function 0 -> acc | m -> aux (acc * m) (m - 1) in
    aux 1 n
end

(** 使用示例 *)
let () =
  Logger.info "Starting application";

  let result1 = Calculator.add 5 3 in
  let result2 = Calculator.multiply 4 7 in
  let result3 = Calculator.divide 10.0 2.0 in

  Printf.printf "5 + 3 = %d\n" result1;
  Printf.printf "4 * 7 = %d\n" result2;
  Printf.printf "10 / 2 = %.1f\n" result3;

  let fib10 = Math.fibonacci 10 in
  let fact5 = Math.factorial 5 in

  Printf.printf "fibonacci(10) = %d\n" fib10;
  Printf.printf "factorial(5) = %d\n" fact5;

  Logger.debug "Application completed"