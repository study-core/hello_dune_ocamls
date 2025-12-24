(** % 扩展示例 - 表达式级别的实际用法 *)

(** ppx_deriving.show - 值到字符串转换 *)
type person = {
  name : string;
  age : int;
  email : string;
} [@@deriving show]

let alice = { name = "Alice"; age = 30; email = "alice@example.com" }
let person_str = [%show: person] alice

(** ppx_deriving.eq - 值相等比较 *)
type point = { x : int; y : int } [@@deriving eq]
let p1 = { x = 1; y = 2 }
let p2 = { x = 1; y = 2 }
let points_equal = [%eq: point] p1 p2

(** ppx_here - 获取源码位置信息 *)
let location = [%here]

(** ppx_env - 获取环境变量 *)
let port = [%env "PORT"]
let debug = [%env "DEBUG"]

(** 自定义扩展示例 *)
let result = [%debug 1 + 2 + 3]
let calc = [%calc 2 * (3 + 4)]

(** 使用示例 *)
let () =
  print_endline person_str;
  print_endline (string_of_bool points_equal);
  Printf.printf "Location: %s:%d\n" location.pos_fname location.pos_lnum;
  print_endline ("Port: " ^ port);
  print_endline ("Debug: " ^ debug)