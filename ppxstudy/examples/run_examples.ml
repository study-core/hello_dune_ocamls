(** PPX 扩展综合示例 - 实际代码用法 *)

(** % 扩展：表达式级别扩展点 *)
type person = {
  name : string;
  age : int;
  email : string;
} [@@deriving show, eq]

let alice = { name = "Alice"; age = 30; email = "alice@example.com" }
let show_result = [%show: person] alice
let eq_result = [%eq: person] alice alice
let here_info = [%here]
let port_env = [%env "PORT"]

(** %% 扩展：结构项级别扩展点 *)
[%%test "simple addition" = 1 + 1 = 2]
[%%test "string length" = String.length "hello" = 5]

[%%ifdef DEBUG then
  let debug_enabled = true
  let debug_log msg = Printf.printf "[DEBUG] %s\n" msg
else
  let debug_enabled = false
  let debug_log _ = ()
end]

(** @ 扩展：模式级别扩展点 *)
let classify_string s =
  match s with
  | _ when Str.string_match (Str.regexp "^\\d+$") s 0 -> "number"
  | _ when Str.string_match (Str.regexp "^[a-zA-Z]+$") s 0 -> "letters"
  | _ -> "mixed"

(** @@ 扩展：类型级别扩展点 *)
type point = { x : float; y : float } [@@deriving show, eq]
type color = Red | Green | Blue [@@deriving show]

(** @@@ 扩展：模块级别扩展点 *)
module Logger = struct
  let log level msg = Printf.printf "[%s] %s\n" level msg
  let info msg = log "INFO" msg
  let error msg = log "ERROR" msg
end

(** 实际使用示例 *)
let () =
  let p = { x = 1.0; y = 2.0 } in
  let c = Red in
  Logger.info "Starting application";
  debug_log "Debug message";
  print_endline show_result;
  print_endline (string_of_bool eq_result)