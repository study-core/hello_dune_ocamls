(*
    文件名称即是模块名称
    文件名 `example.ml` => 模块名称为 `Example`
*)


(* 模块定义 *)
(* 
    module Hello : sig val message : string val hello : unit -> unit end   
*)
module Hello = struct
  let message = "Hello"    (* 字段 *)
  let hello () = print_endline message  (* 方法 *)
end;;

(* 调用 Hello 模块的 hello() 方法 *)
Hello.hello ();;
(* 
    - : unit = ()   
*)
Hello


(* 

(* 不打开直接使用 *)
(* 列表 *)
# List.length [1; 2; 3];;


通过 open 打开模块  可以 省略  `模块名称`

与 python 中 from hoge import * 类似


(* 打开模块， 再使用 *)
# open List;;
# length [1; 2; 3];;
- : int = 3

*)



(* 
    定义 => module type 签名名 = sig … end
    应用 => module 模块名 : 签名名 = 模块名或 struct … end   
*)






(* 
    签名定义
    module type AbstTypeSig = sig type t val get_t : int -> t val print : t -> unit end
*)
module type AbstTypeSig = sig
  type t (* 抽象数据类型 *)
  val get_t : int -> t
  val print : t -> unit
end;;


(* 
   模块定义
   module AbstTypeInt : AbstTypeSig
*)
module AbstTypeInt : AbstTypeSig = struct
  type t = int
  let get_t i = i
  let print t = print_int t
end;;


(* 
    如果返回值是一个抽象数据类型 <abstr>
    val t : AbstTypeInt.t = <abstr>
*)
let t = AbstTypeInt.get_t 0;;

(* 
    0- : unit = ()   
*)
AbstTypeInt.print t;;


(* 
    抽象数据类型不能在外部处理
    
    AbstTypeInt.t 是一个真正的int，但是因为它隐藏着一个抽象的数据类型
    print_int 即使是作为参数引用
    
    Error: This expression has type AbstTypeInt.t
         but an expression was expected of type int
*)
let () = print_int t;;
