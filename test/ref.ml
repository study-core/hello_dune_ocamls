
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


(* ----------------------------------------------------------------------------------------- *)
(* ----------------------------------------- 可选参数 -------------------------------------- *)


(* 
  ref创建一个单独的可变值。ref类型是标准库中预定义的，并没有什么特别的，它只是一个普通的记录类型，拥有一个名为contents的单独的可变字段   
*)
(* 
  val x : int ref = {contents = 0}   
*)
let x = { contents = 0 };;


(* 
  - : unit = ()   
*)
x.contents <- x.contents + 1;;

(* 
  - : int ref = {contents = 1}   
*)
x;;



(* ----------------------------------------------------------------------------------------- *)
(* --------------------------------------- 函数及操作符 ------------------------------------ *)


(* val x : int ref = {contents = 0} *)
let x = ref 0  (* create a ref, i.e., { contents = 0 } *) ;;


(* - : int = 0 *)
!x (* get the contents of a ref, i.e., x.contents *) ;;


(* - : unit = () *)
x := !x + 1    (* assignment, i.e., x.contents <- ... *) ;;


(* - : int = 1 *)
!x ;;


(* ----------------------------------------------------------------------------------------- *)
(* ---------------------------  重新实现ref类型和所有这些操作符  --------------------------- *)


type 'a ref = { mutable contents : 'a }

  let ref x = { contents = x }
  let (!) r = r.contents
  let (:=) r x = r.contents <- x
  ;;

(* 
  val ref : 'a -> 'a ref = <fun>
  val ( ! ) : 'a ref -> 'a = <fun>
  val ( := ) : 'a ref -> 'a -> unit = <fun>
*)
type 'a ref = { mutable contents : 'a; }
