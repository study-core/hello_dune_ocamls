(* 

这里使用 Yojson



opam install yojson  安装

*)

(* 使用 *)   (**  一定需要先这样使用，才可以用  *)
#use "topfind";;
#require "yojson";;  
open Yojson;;



let json_string = {|
  {"number" : 42,
   "string" : "yes",
   "list": ["for", "sure", 42]
  }
|}
(* val json_string : string *)

let json = Yojson.Safe.from_string json_string
(* val json : Yojson.Safe.t *)

let () = Format.printf "Parsed to %a" Yojson.Safe.pp json