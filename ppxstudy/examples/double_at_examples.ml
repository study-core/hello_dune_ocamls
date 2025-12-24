(** @@ 扩展示例 - 类型级别的实际用法 *)

(** deriving show - 自动生成显示函数 *)
type person = {
  name : string;
  age : int;
  email : string;
} [@@deriving show]

(** deriving eq - 自动生成比较函数 *)
type point = { x : int; y : int } [@@deriving eq]

(** deriving yojson - 自动生成 JSON 序列化 *)
type config = {
  host : string;
  port : int;
  debug : bool;
} [@@deriving yojson]

(** deriving sexp - 自动生成 S-表达式序列化 *)
type color = Red | Green | Blue | RGB of int * int * int [@@deriving sexp]

(** 组合多个 deriving *)
type user = {
  id : int;
  username : string;
  email : string;
  active : bool;
} [@@deriving show, eq, yojson]

(** 使用示例 *)
let () =
  let person = { name = "Alice"; age = 30; email = "alice@test.com" } in
  let p1 = { x = 1; y = 2 } in
  let p2 = { x = 1; y = 2 } in
  let config = { host = "localhost"; port = 8080; debug = true } in
  let user = { id = 1; username = "alice"; email = "alice@test.com"; active = true } in

  print_endline ([%show: person] person);
  print_endline (string_of_bool ([%eq: point] p1 p2));
  print_endline (Yojson.Safe.to_string ([%yojson_of: config] config));
  print_endline (Sexplib.Sexp.to_string ([%sexp_of: color] Red));
  print_endline ([%show: user] user)