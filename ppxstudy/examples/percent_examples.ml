(** % 扩展示例 - 表达式级别的实际用法 *)

(** ppx_deriving.show - 值到字符串转换（第三方库：ppx_deriving）*)
type person = {
  name : string;
  age : int;
  email : string;
} [@@deriving show]

let alice = { name = "Alice"; age = 30; email = "alice@example.com" }
let person_str = [%show: person] alice

(** 展开后代码（[%show: person]）：
    let person_str = show_person alice
    (* 其中 show_person 是 ppx_deriving 库的 [@@deriving show] 生成的函数 *)
*)

(** ppx_deriving.eq - 值相等比较（第三方库：ppx_deriving）*)
type point = { x : int; y : int } [@@deriving eq]
let p1 = { x = 1; y = 2 }
let p2 = { x = 1; y = 2 }
let points_equal = [%eq: point] p1 p2

(** 展开后代码（[%eq: point]）：
    let points_equal = equal_point p1 p2
    (* 其中 equal_point 是 ppx_deriving 库的 [@@deriving eq] 生成的函数 *)
*)

(** ppx_here - 获取源码位置信息（第三方库：ppx_here）*)
let location = [%here]

(** 展开后代码（[%here]）：
    let location = { Lexing.pos_fname = "percent_examples.ml";
                     pos_lnum = 20;  (* 当前行号 *)
                     pos_bol = ...;   (* 行开始位置 *)
                     pos_cnum = ... } (* 字符位置 *)
*)

(** ppx_env - 获取环境变量（第三方库：ppx_env）*)
let port = [%env "PORT"]
let debug = [%env "DEBUG"]

(** 展开后代码（[%env "PORT"]）：
    let port = try Sys.getenv "PORT" with Not_found -> ""
    (* 如果环境变量不存在，返回空字符串 *)
*)

(** 自定义扩展示例 *)
let result = [%debug 1 + 2 + 3]
let calc = [%calc 2 * (3 + 4)]

(** 展开后代码（[%debug 1 + 2 + 3]）：
    let result =
      Printf.printf "🐛 [DEBUG] 表达式: 1 + 2 + 3\n";
      let result = 1 + 2 + 3 in
      Printf.printf "🐛 [DEBUG] 结果: 6\n";
      result
*)

(** 展开后代码（[%calc 2 * (3 + 4)]）：
    let calc = 14  (* 在编译时计算出结果 *)
*)

(** 使用示例 *)
let () =
  print_endline person_str;
  print_endline (string_of_bool points_equal);
  Printf.printf "Location: %s:%d\n" location.pos_fname location.pos_lnum;
  print_endline ("Port: " ^ port);
  print_endline ("Debug: " ^ debug)