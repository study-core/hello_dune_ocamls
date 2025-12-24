(** %% 扩展示例 - 结构项级别的实际用法 *)

(** 内联测试 *)
[%%test "addition" = 1 + 1 = 2]
[%%test "string ops" = String.length "hello" = 5]

(** 展开后代码（[%%test]）：
    (* 这些测试在编译时执行，如果失败会报错 *)
    let () =
      if not (1 + 1 = 2) then failwith "test addition failed";
      if not (String.length "hello" = 5) then failwith "test string ops failed"
*)

(** 条件编译 *)
[%%ifdef DEBUG then
  let debug_mode = true
  let debug msg = Printf.printf "[DEBUG] %s\n" msg
else
  let debug_mode = false
  let debug _ = ()
end]

(** 展开后代码（[%%ifdef DEBUG]）：
    (* 如果定义了DEBUG环境变量或编译时定义： *)
    let debug_mode = true
    let debug msg = Printf.printf "[DEBUG] %s\n" msg

    (* 如果没有定义DEBUG： *)
    let debug_mode = false
    let debug _ = ()
*)

(** 性能基准测试 *)
let fib n =
  let rec f a b = function 0 -> a | n -> f b (a+b) (n-1) in
  f 0 1 n

[%%bench "fibonacci 10" = fib 10]
[%%bench "fibonacci 20" = fib 20]

(** 展开后代码（[%%bench]）：
    (* 这些基准测试在编译时执行，用于性能回归测试 *)
    let () =
      let start_time = Unix.gettimeofday () in
      let result1 = fib 10 in
      let end_time = Unix.gettimeofday () in
      let elapsed = end_time -. start_time in
      if elapsed > expected_time then
        failwith (Printf.sprintf "benchmark fibonacci 10 regressed: %.3f > %.3f" elapsed expected_time)
      (* 类似处理 fibonacci 20 *)
*)

(** 自定义扩展示例 *)
[%%auto let greet name = Printf.printf "Hello, %s!\n" name]

(** 展开后代码（[%%auto]）：
    (* 假设 %%auto 扩展会自动生成相关的代码 *)
    let greet name = Printf.printf "Hello, %s!\n" name
    let greet_all names = List.iter greet names  (* 自动生成的辅助函数 *)
*)

(** 使用示例 *)
let () =
  debug "This is a debug message";
  print_endline ("Debug mode: " ^ string_of_bool debug_mode);
  print_endline ("fib 10 = " ^ string_of_int (fib 10))