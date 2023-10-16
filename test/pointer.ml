(* 
######################################################################################################################################################
指针   
######################################################################################################################################################
*)

(* 
一个指针的值不是null就是某个内存地址   
*)

(* 
type 'a pointer = Null | Pointer of 'a ref   
*)
type 'a pointer = Null | Pointer of 'a ref;;  (* ++++++++++++++++++++++++++++++++++++++++++++++++++++ 要我肯定会写反的  ref 'a ++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* 
定义 指针 赋值和解引用 函数 示例：   
*)

let ( !^ ) = function    (* 解引用函数定义：  val ( !^ ) : 'a pointer -> 'a = <fun> *)
    | Null -> invalid_arg "Attempt to dereference the null pointer"
    | Pointer r -> !r;;

let ( ^:= ) p v =  (* 赋值函数定义： val ( ^:= ) : 'a pointer -> 'a -> unit = <fun> *)
    match p with
    | Null -> invalid_arg "Attempt to assign the null pointer"
    | Pointer r -> r := v;;

(* 初始化 *)
let new_pointer x = Pointer (ref x);;   (* val new_pointer : 'a -> 'a pointer = <fun>  *)

(* 将指针 指向 整数 *)
let p = new_pointer 0;;  (* val p : int pointer = Pointer {contents = 0} *)

p ^:= 1;;  (* 赋值 1,  - : unit = () *)
!^p;;  (* 解引用,  - : int = 1 *)


(* val r : int ref = {contents = 0} *)
let r = ref 0;;

(* 赋值给引用 - : unit = () *)
r := 100;;

(* 解引用 - : int = 100 *)
!r;;
