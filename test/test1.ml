

(* 定义类型 value ,  Int x , Bool x 均为类型 value *)
type value =
  | Int of int
  | Bool of bool


(* 
   类型 expr 
*)
type expr =
  | Value of value
  | Eq of expr * expr
  | Plus of expr * expr
  | If of expr * expr * expr


(* 
   定义无参的异常  Ill_typed 


   有参的异常定义为:   Ill_typed of String 之类， 使用为 Ill_typed "xx" 或 Ill_typed ("xx")
*)
exception Ill_typed


(* 
定义 评估器 函数

用于评估： 当遇到尝试添加 bool 和 int 的表达式时，可以抛出该异常
*)
let rec eval expr =

  match expr with           (* 匹配 表达式 *)
  | Value v -> v            (* 如果表达式是 Value of value 则直接返回 value *)
  | If (c, t, e) ->         (* 如果表达式是 IF of expr * expr * expr 则继续匹配 eval c 的返回值 *)
    (match eval c with                            (* 匹配  eval c 的返回值 *)
     | Bool b -> if b then eval t else eval e     (* 如果是类型 Bool of b, 则看 b 是 true 还是 false 去分别求 eval t 或 eval e 的返回值 *)
     | Int _ -> raise Ill_typed)                  (* 如果是类型 Int of x 则报错*)
  | Eq (x, y) ->
    (match eval x, eval y with                        (* 同时匹配 eval x 和 eval y 的返回值 *)
     | Bool _, _ | _, Bool _ -> raise Ill_typed       (* 如果 eval x 返回 Bool of x, eval y 返回任意, 则 balabala*)
     | Int f1, Int f2 -> Bool (f1 = f2))              (* 如果 eval x 返回 Int of f1, eval y 返回 Int of f2, 则 对 f1、f2 做 结构比较 *)
  | Plus (x, y) ->
    (match eval x, eval y with
     | Bool _, _ | _, Bool _ -> raise Ill_typed
     | Int f1, Int f2 -> Int (f1 + f2));;



(* 类型 *)
module type Typesafe_lang_sig = sig
  type 'a t

  (** functions for constructing expressions *)

  val int : int -> int t
  val bool : bool -> bool t
  val if_ : bool t -> 'a t -> 'a t -> 'a t
  val eq : 'a t -> 'a t -> bool t
  val plus : int t -> int t -> int t

  (** Evaluation functions *)

  val int_eval : int t -> int
  val bool_eval : bool t -> bool
end


(* 类型的实现 *)
module Typesafe_lang : Typesafe_lang_sig = struct
  type 'a t = expr

  let int x = Value (Int x)
  let bool x = Value (Bool x)
  let if_ c t e = If (c, t, e)
  let eq x y = Eq (x, y)
  let plus x y = Plus (x, y)

  let int_eval expr =
    match eval expr with
    | Int x -> x
    | Bool _ -> raise Ill_typed

  let bool_eval expr =
    match eval expr with
    | Bool x -> x
    | Int _ -> raise Ill_typed
end

(* 


let expr = Typesafe_lang.(plus (int 3) (bool false));;
(* 
Error: This expression has type bool t but an expression was expected of type
         int t
       Type bool is not compatible with type int
*)

*)

(* val expr : bool Typesafe_lang.t = <abstr> *)
let expr = Typesafe_lang.(eq (bool true) (bool false));;


(* 看起来它在表达式类型上是多态的，但求值器仅支持检查 Int 的相等性 *)
(* Exception: Ill_typed. *)
Typesafe_lang.bool_eval expr;;








     
(* 为 value 和 expr 类型加上 类型参数 *)
type 'a value =
  | Int of 'a
  | Bool of 'a

type 'a expr =
  | Value of 'a value
  | Eq of 'a expr * 'a expr
  | Plus of 'a expr * 'a expr
  | If of bool expr * 'a expr * 'a expr



let i x = Value (Int x)  (* 函数 i 的参数为：  'a -> 'a expr *)
and b x = Value (Bool x)
and (+:) x y = Plus (x,y);; (* 函数 (+:) 参数为: 'a expr -> 'a expr -> 'a expr *)



i 3;;

b false;;

i 3 +: i 4;;

(* 

外部表达式的类型始终等于内部表达式的类型，这意味着某些应该进行类型检查的内容不需要进行类型检查

所以还是会出错
   
*)
(* If (Eq (i 3, i 4), i 0, i 1);;
(* 
Error: This expression has type int expr
       but an expression was expected of type bool expr
       Type int is not compatible with type bool   
*) *)

(* 结论：  普通变体不支持我们想要使用类型参数的方式  *)


(* 

想要做到： 希望 【类型参数】 以不同的方式填充在不同的标签中，并以非平凡的方式依赖于与每个标签关联的数据的类型。
   

请使用 GADT 
*)