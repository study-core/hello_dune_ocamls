

#use "topfind";;
#require "ppx_deriving_yojson";;
#require "yojson";;

type person = {
  username: string [@key "username1"];
  name: string [@key "name2"];
  sensors: int list [@key "sensors3"];
} [@@deriving yojson]

(* type person = {
  username: string;
  name: string;
  sensors: int list;
} [@@deriving to_yojson] *)


let my_person = { username = "xu"; name = "Gavin"; sensors = [12; 36] }

let () = print_endline (Yojson.Safe.pretty_to_string (person_to_yojson my_person))   (* 打印 json *)