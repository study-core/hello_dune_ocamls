(*
    文件名称   即是   模块名称
    文件名 `example.ml` => 模块名称为 `Example`
*)


(* 模块定义 *)
(* 
    模块的类型为:  

    module Hello : sig    val message : string     val hello : unit -> unit    end  


    模块的类型定义： (函子)

    module type ELEMENT = sig type t val compare : t -> t -> int end
    
模块的定义为，如下：




没有提供  模块签名， 直接定义  模块， 则 在其他模块中可以 直接通过 Hello.message 和 Hello.hello() 去访问 Hello  模块的成员


但是提供 模块签名 后，在其他模块中不能 直接访问 Hello.message 和 Hello.hello()


*)
module Hello = struct
  let message = "Hello"    (* 字段 *)
  let hello () = print_endline message  (* 方法 *)
end;;

(* 调用 Hello 模块的 hello() 方法 *)
Hello.hello ();;
(* 
    - : unit = ()   

    Hello;;
*)



(* 

(* 不打开直接使用 *)
(* 列表 *)
# List.length [1; 2; 3];;


通过 open 打开模块  可以 省略  `模块名称` 和  rust 中的 use 类似 


但是 #require 和 go 的 import 类似？？？？？？？？？？？


(* 打开模块， 再使用 *)
# open List;;
# length [1; 2; 3];;
- : int = 3

*)



(* 
********************************************************************
********************************************************************

    定义 => module type 签名名 = sig … end

    应用 => module 模块名 : 签名名 = 模块名或 struct … end   

********************************************************************
********************************************************************    
*)






(* 
****************************************************************************************************************************************

    OCaml 的 module 其实有点像  Rust 的 Trait 的， 个人总结， 
    
    特别是           sig  type x ... end 

    和看完 functor 函子部分的使用就更加这么觉得了






    签名定义:

    module type AbstTypeSig = sig type t val get_t : int -> t val print : t -> unit end

****************************************************************************************************************************************    
*)
module type AbstTypeSig = sig
  type t (* 抽象数据类型 ，类似 rust 的  关联类型*)
  val get_t : int -> t
  val print : t -> unit
end;;



(* 
****************************************************************************************************************************************

   模块定义:

   module AbstTypeInt : AbstTypeSig

****************************************************************************************************************************************    
*)
module AbstTypeInt : AbstTypeSig = struct
  type t = int
  let get_t i = i
  let print t = print_int t
end;;



(* 
****************************************************************************************************************************************

    如果返回值是一个抽象数据类型 <abstr>

    val t : AbstTypeInt.t = <abstr>

****************************************************************************************************************************************    
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


(* 
    ####################################################################################################################
    ####################################################################################################################
    ##  很多时候将接口信息定义在 mli 文件中，mli 用户可以直接写，也可以用命令 从 ml 生成 mli                          ##
    ##  从 ml 生成 mli：                                                                                              ##
    ##  ocamlc -i aa.ml > aa.mli                                                                                      ##
    ####################################################################################################################
    ####################################################################################################################

*)


(* 
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################

对某个已有的模块拓展

######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
*)

(* 
****************************************************************************************************************************************
****************************************************************************************************************************************






如 想要为已有 List 模块添加自定义的函数 optmap  这时可以类似： 添加一个 `extensions.ml` 中使用 include 

定义如：









module List = struct  (* 这个是 我们自定义的 List 模块 *)

  include List  (* 引入原有的 List 模块 *)

  let rec optmap f = function  (* 我们添加的 optmap 函数 *)
    | [] -> []
    | hd :: tl ->
       match f hd with
       | None -> optmap f tl
       | Some x -> x :: optmap f tl
  end;;






****************************************************************************************************************************************
****************************************************************************************************************************************  



********************************************************************

类型为： 


module List :
  sig
    type 'a t = 'a list = [] | (::) of 'a * 'a list
    val length : 'a t -> int
    val compare_lengths : 'a t -> 'b t -> int
    val compare_length_with : 'a t -> int -> int
    val cons : 'a -> 'a t -> 'a t
    val hd : 'a t -> 'a
    val tl : 'a t -> 'a t
    val nth : 'a t -> int -> 'a
    val nth_opt : 'a t -> int -> 'a option
    val rev : 'a t -> 'a t
    val init : int -> (int -> 'a) -> 'a t
    val append : 'a t -> 'a t -> 'a t
    val rev_append : 'a t -> 'a t -> 'a t
    val concat : 'a t t -> 'a t
    val flatten : 'a t t -> 'a t
    val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
    val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
    val iter : ('a -> unit) -> 'a t -> unit
    val iteri : (int -> 'a -> unit) -> 'a t -> unit
    val map : ('a -> 'b) -> 'a t -> 'b t
    val mapi : (int -> 'a -> 'b) -> 'a t -> 'b t
    val rev_map : ('a -> 'b) -> 'a t -> 'b t
    val filter_map : ('a -> 'b option) -> 'a t -> 'b t
    val concat_map : ('a -> 'b t) -> 'a t -> 'b t
    val fold_left_map : ('a -> 'b -> 'a * 'c) -> 'a -> 'b t -> 'a * 'c t
    val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a
    val fold_right : ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val iter2 : ('a -> 'b -> unit) -> 'a t -> 'b t -> unit
    val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
    val rev_map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
    val fold_left2 : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b t -> 'c t -> 'a
    val fold_right2 : ('a -> 'b -> 'c -> 'c) -> 'a t -> 'b t -> 'c -> 'c
    val for_all : ('a -> bool) -> 'a t -> bool
    val exists : ('a -> bool) -> 'a t -> bool
    val for_all2 : ('a -> 'b -> bool) -> 'a t -> 'b t -> bool
    val exists2 : ('a -> 'b -> bool) -> 'a t -> 'b t -> bool
    val mem : 'a -> 'a t -> bool
    val memq : 'a -> 'a t -> bool
    val find : ('a -> bool) -> 'a t -> 'a
    val find_opt : ('a -> bool) -> 'a t -> 'a option
    val find_map : ('a -> 'b option) -> 'a t -> 'b option
    val filter : ('a -> bool) -> 'a t -> 'a t
    val find_all : ('a -> bool) -> 'a t -> 'a t
    val filteri : (int -> 'a -> bool) -> 'a t -> 'a t
    val partition : ('a -> bool) -> 'a t -> 'a t * 'a t
    val partition_map : ('a -> ('b, 'c) Either.t) -> 'a t -> 'b t * 'c t
    val assoc : 'a -> ('a * 'b) t -> 'b
    val assoc_opt : 'a -> ('a * 'b) t -> 'b option
    val assq : 'a -> ('a * 'b) t -> 'b
    val assq_opt : 'a -> ('a * 'b) t -> 'b option
    val mem_assoc : 'a -> ('a * 'b) t -> bool
    val mem_assq : 'a -> ('a * 'b) t -> bool
    val remove_assoc : 'a -> ('a * 'b) t -> ('a * 'b) t
    val remove_assq : 'a -> ('a * 'b) t -> ('a * 'b) t
    val split : ('a * 'b) t -> 'a t * 'b t
    val combine : 'a t -> 'b t -> ('a * 'b) t
    val sort : ('a -> 'a -> int) -> 'a t -> 'a t
    val stable_sort : ('a -> 'a -> int) -> 'a t -> 'a t
    val fast_sort : ('a -> 'a -> int) -> 'a t -> 'a t
    val sort_uniq : ('a -> 'a -> int) -> 'a t -> 'a t
    val merge : ('a -> 'a -> int) -> 'a t -> 'a t -> 'a t
    val to_seq : 'a t -> 'a Seq.t
    val of_seq : 'a Seq.t -> 'a t
    val optmap : ('a -> 'b option) -> 'a t -> 'b t
  end


它创建了一个模块 Extensions.List ，它具有标准 List 模块所具有的一切，以及一个新的 optmap 函数。
在另一个文件中，要覆盖默认的 List 模块，我们所要做的就是 .ml 文件开头的 open Extensions ：  

open Extensions

...

List.optmap ...
*)



