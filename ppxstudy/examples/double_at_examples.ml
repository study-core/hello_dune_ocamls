(** @@ 扩展示例 - 类型级别的实际用法 *)

(** deriving show - 自动生成显示函数 *)
type person = {
  name : string;
  age : int;
  email : string;
} [@@deriving show]

(** 展开后代码（ppx_deriving.show 生成）：
    type person = { name : string; age : int; email : string; }
    let pp_person fmt v = Fmt.pf fmt "{ name = %S; age = %d; email = %S }" v.name v.age v.email
    let show_person v = Format.asprintf "%a" pp_person v
*)

(** deriving eq - 自动生成比较函数（第三方库：ppx_deriving）*)
type point = { x : int; y : int } [@@deriving eq]

(** 展开后代码（ppx_deriving.eq 生成）：
    type point = { x : int; y : int }
    let equal_point lhs rhs = lhs.x = rhs.x && lhs.y = rhs.y
*)

(** deriving yojson - 自动生成 JSON 序列化（第三方库：ppx_yojson_conv）*)
type config = {
  host : string;
  port : int;
  debug : bool;
} [@@deriving yojson]

(** 展开后代码（ppx_yojson_conv 生成）：
    type config = { host : string; port : int; debug : bool; }
    let yojson_of_config {host; port; debug} =
      `Assoc [("host", `String host); ("port", `Int port); ("debug", `Bool debug)]
    let config_of_yojson = function
      | `Assoc [("host", `String host); ("port", `Int port); ("debug", `Bool debug)] ->
          {host; port; debug}
      | _ -> failwith "invalid config JSON"
*)

(** deriving sexp - 自动生成 S-表达式序列化（第三方库：ppx_sexp_conv）*)
type color = Red | Green | Blue | RGB of int * int * int [@@deriving sexp]

(** 展开后代码（ppx_sexp_conv 生成）：
    type color = Red | Green | Blue | RGB of int * int * int
    let sexp_of_color = function
      | Red -> Sexplib.Sexp.Atom "Red"
      | Green -> Sexplib.Sexp.Atom "Green"
      | Blue -> Sexplib.Sexp.Atom "Blue"
      | RGB (r, g, b) -> Sexplib.Sexp.List [Atom "RGB"; sexp_of_int r; sexp_of_int g; sexp_of_int b]
*)

(** 组合多个 deriving（第三方库：ppx_deriving）*)
type user = {
  id : int;
  username : string;
  email : string;
  active : bool;
} [@@deriving show, eq, yojson]

(** 展开后代码（组合多个 deriving）：
    type user = { id : int; username : string; email : string; active : bool; }
    let pp_user fmt v = Fmt.pf fmt "{ id = %d; username = %S; email = %S; active = %B }"
                        v.id v.username v.email v.active
    let show_user v = Format.asprintf "%a" pp_person v
    let equal_user lhs rhs = lhs.id = rhs.id && lhs.username = rhs.username &&
                            lhs.email = rhs.email && lhs.active = rhs.active
    let yojson_of_user {id; username; email; active} =
      `Assoc [("id", `Int id); ("username", `String username);
              ("email", `String email); ("active", `Bool active)]
*)

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