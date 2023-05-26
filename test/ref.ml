
(* 
创建引用 h 和 f
  val h : string ref = {contents = "Hoge"}
  val f : string ref = {contents = "Fuga"} 
*)
let h = ref "Hoge" and f = ref "Fuga";;


(* 
  获取 引用 h 和 f 并拼接
  HogeFuga
*)
let () = print_string (!h ^ !f ^ "\n");;

(* 
  重写 引用 h  (这里用 f 所引用的值重写它)
  - : unit = ()
*)
h := !f;;
let () = print_string (!h ^ !f ^ "\n");;