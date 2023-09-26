(* 
######################################################################################################################################################
命名参数 
######################################################################################################################################################
*)

(* 使用带标签的参数定义函数 *)
(* 
    类似 python 中的命名参数
    当指定了参数名称 first  和 last 后，后续传参可以不按照顺序，而是按照名称

    val range : first:int -> last:int -> int list = <fun>
*)
let rec range ~first: a  ~last: b = 
  if a > b then []
  else a :: range ~first: (a + 1) ~last: b;;
  

(* 指定参数的值，调用函数 *)
(* 
    - : int list = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10]   
    - : int list = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10]  
*)
range ~first: 1 ~last: 10;;

range ~last: 10 ~first: 1;;



(* 除非指定了标签名称，否则按标签名称定义应用 *) 

(* - : int list = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10] *)
range 1 10;;

(* - : int list = [] *)
range 10 1;;


(* 
********************************************************************
命名参数的简写方法  
******************************************************************** 
*)

(* val may : f:('a -> 'b) -> 'a option -> unit = <fun> *)
(* 参数 ~f 只是 ~f:f 的简写（即标签是 ~f ，函数中使用的变量是 f ） *)
let may ~f x =
  match x with
  | None -> ()
  | Some x -> ignore (f x);;


may;; (*  *)
   
may ~f:print_endline None;;  (* - : unit = () *)
  
may ~f:print_endline (Some "hello");;  (* 输出 hello    类型 - : unit = () *)
  
  


(* 
######################################################################################################################################################
可选参数
######################################################################################################################################################
*)

(* val concat : ?sep:string -> string -> string -> string = <fun> *)
let concat ?sep x y = 
  let s = match sep with None->"" | Some x -> x in
  x ^ s ^ y;; 
     


  (*   - : string = "dogcat"   *)
concat "dog" "cat";;
   

(* - : string = "dog,cat"  *)
concat "dog" "cat" ~sep:",";;


(* 
      默认值1给出步骤值
      val range : ?step:int -> int -> int -> int list = <fun>
*)
let rec range ?(step = 1) a b = 
  if a > b then []
  else a :: range ~step (a + step) b;;


(* - : int list = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10] *)
range 1 10;;



(* 
    - : int list = [1; 3; 5; 7; 9]  
*)

range 1 10 ~step:2;;



(* 
    - : int list = [1; 4; 7; 10]   
*)
range 1 ~step:3 10;;


(* 

range 2 1 10;;

以上这个会报错
      Error: The function applied to this argument has type ?step:int -> int list
      This argument cannot be applied without label   

*)




(* 
********************************************************************
示例
********************************************************************
*)

(* val may : f:('a -> 'b) -> 'a option -> unit = <fun> *)
let may ~f x =
  match x with
  | None -> ()
  | Some x -> ignore (f x);;


(* 
type window = {
  mutable title : string;
  mutable width : int;
  mutable height : int;  
}   
*)
type window =
  {mutable title: string;
   mutable width: int;
   mutable height: int};;

let create_window () = {title = "none"; width = 640; height = 480;};;   (* val create_window : unit -> window = <fun> *)

let set_title window title = window.title <- title;;  (* val set_title : window -> string -> unit = <fun> *)

let set_width window width = window.width <- width;;  (* val set_width : window -> int -> unit = <fun> *)

let set_height window height = window.height <- height;;  (* val set_height : window -> int -> unit = <fun> *)

(*   
为什么 open_window 要用 () ?

因为当 ?title ?width ?height 三者都不传时， open_window () 则能表示是 函数的调用 入参为 uint， 而 open_window;; 则不是为函数调用

当定义为 let open_window ?title ?width ?heigh 时，则 ?title ?width ?height 三者都不传时，就会是 open_window;;， 从而不是函数 ... 当然需要报错啊
 *)
let open_window ?title ?width ?height () =
  let window = create_window () in
  may ~f:(set_title window) title;      (* set_title window 是偏函数，得到 val fn: string -> uint = <fun> *)
  may ~f:(set_width window) width;      (* set_width window 是偏函数，得到 val fn: int -> uint = <fun> *)
  may ~f:(set_height window) height;    (* set_height window 是偏函数，得到 val fn: int -> uint = <fun> *)

window;;  (* val open_window : ?title:string -> ?width:int -> ?height:int -> unit -> window = <fun> *)



(* 
********************************************************************
错误的示例
******************************************************************** 

let open_application ?width ?height () =
  open_window ~title:"My Application" ~width ~height;;
Error: This expression has type 'a option
       but an expression was expected of type int
*)

(* 
正确的示例

在函数调用中编写 ?width 是编写 ~width:(unwrap width) 的简写，其中 unwrap 是一个删除 width 周围的“ option 包装器”的函数

表示不要  'a option 而是要 'a

val open_application : ?width:int -> ?height:int -> unit -> unit -> window = <fun>
*)
let open_application ?width ?height () =
  open_window ~title:"My Application" ?width ?height;;  (* 在函数调用中编写 ?width 是编写 ~width:(unwrap width) 的简写，其中 unwrap 是一个删除 width 周围的“ option 包装器”的函数 *)



(* 
######################################################################################################################################################  
多态变体   (查看 constructor_test.ml) 
######################################################################################################################################################
*)