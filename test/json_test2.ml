(*
  dune exec examples/constructing.exe <<EOF
{
  "id": "398eb027",
  "name": "John Doe",
  "pages": [
    {
      "id": 1,
      "title": "The Art of Flipping Coins",
    }
  ]
}
EOF
*)

#use "topfind";;
#require "yojson";;  
open Yojson;;

let json_output =
  `Assoc
    [
      ("id", `String "398eb027");
      ("name", `String "John Doe");
      ( "pages",
        `Assoc
          [ ("id", `Int 1); ("title", `String "The Art of Flipping Coins") ] );
    ]

    (* 
       自定义一个叫做  main 的函数 入参为 ()，名字是自定义的也可以不叫 main ， 因为程序的真正入口为:   
       
              let () = ...
    *)
let main () =
  let oc = stdout in
  Yojson.Basic.pretty_to_channel oc json_output;
  output_string oc "\n"

  (* main 入口 *)
let () = main ()