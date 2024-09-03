#use "topfind";;
#require "ppx_deriving_yojson";;



type t = {x: int; y: int} [@@deriving to_yojson]
type u = {s: string; pos: t} [@@deriving to_yojson]

let item = {s= "hello"; pos={x= 1; y= 2}};;
let () = print_endline (Yojson.Safe.pretty_to_string (u_to_yojson item))   (* 打印 json *)