(** %% 扩展示例 - 结构项级别的实际用法 *)

(** 内联测试 *)
[%%test "addition" = 1 + 1 = 2]
[%%test "string ops" = String.length "hello" = 5]

(** 条件编译 *)
[%%ifdef DEBUG then
  let debug_mode = true
  let debug msg = Printf.printf "[DEBUG] %s\n" msg
else
  let debug_mode = false
  let debug _ = ()
end]

(** 性能基准测试 *)
let fib n =
  let rec f a b = function 0 -> a | n -> f b (a+b) (n-1) in
  f 0 1 n

[%%bench "fibonacci 10" = fib 10]
[%%bench "fibonacci 20" = fib 20]

(** 使用示例 *)
let () =
  debug "This is a debug message";
  print_endline ("Debug mode: " ^ string_of_bool debug_mode);
  print_endline ("fib 10 = " ^ string_of_int (fib 10))