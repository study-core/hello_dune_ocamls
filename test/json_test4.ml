#use "topfind";;
#require "ppx_deriving_yojson";;
(* #require "yojson";; *)

(* open Yojson;; *)

(* Define an OCaml type *)
type person = {
  name : string;
  age : int;
  } 
[@@deriving to_yojson]

(* Example person *)
let my_person = { name = "Gavin"; age = 36 }
(* let xx = person_to_yojson my_person *)

(* Convert person to JSON and store in a file *)
let store_person_as_json_file filename person =
  let json_str = Yojson.Safe.to_string (person_to_yojson person) in

  (* 流操作 *)
  let oc = open_out filename in
  output_string oc json_str;
  close_out oc

(* Usage *)
let () = store_person_as_json_file "person.json" my_person