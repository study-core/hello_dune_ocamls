(* 
    创建引用 r1 和 r2
    val r1 : int ref = {contents = 5}
    val r2 : int ref = {contents = 2}
*)
let r1 = ref 5 and r2 = ref 2;;

(* 
    引用的引用创建 rr1 和 rr2
    val rr1 : int ref ref = {contents = {contents = 5}}
    val rr2 : int ref ref = {contents = {contents = 2}}
*)
let rr1 = ref r1 and rr2 = ref r2;;


(* 
    引用操作 将 2 赋值给 r1
    ∵ !rr2 => r2  ∴ !(!rr2) => !r2 => 2
*)
let () = !rr1 := !(!rr2);;
(* 
  - : int * int = (2, 2)
*)
(!r1, !r2);;
let () = print_string ((string_of_int !r1) ^ (string_of_int !r2) ^ "\n");;



(* 异常定义 *)
(* 
    exception Hoge   
*)
exception Hoge;;

(* 
    exception Fuga of string
*)
exception Fuga of string;;

(* 
    Exception: Hoge
*)
raise Hoge;;

(* 
    Exception: Fuga "fuga!"
*)
raise (Fuga "fuga!");;


(* exception Hoge *)
exception Hoge;;


(* 
    exn 类型列表
    val exnlist : exn list = [Not_found; Hoge; Invalid_argument "fuga"]
*)
let exnlist = [Not_found; Hoge; (Invalid_argument "fuga")];;


(* 
    接收exn类型的函数
    val f : exn -> string = <fun>
*)
let f = function
  | Hoge -> "hoge!"
  | x -> raise x;;

(* - : string = "hoge!" *)
f Hoge;;

(* 
    Exception: Not_found
*)
f Not_found;;
