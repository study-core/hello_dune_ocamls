(* 
    一种机制，可以为多种变体类型使用通用的构造函数  
    新的  函子 
*)
(* 
    消除 “1构造函数<=> 1变体” 的限制   
*)


(* - : [> `Hoge ] = `Hoge *)
`Hoge;;

(* - : [> `Hoge of int ] = `Hoge 2 *)
`Hoge 2;;

(* - : [> `Hoge of [> `Fuga ] ] = `Hoge `Fuga *)
`Hoge `Fuga;;


(* 
      val f : bool -> [> `Fuga | `Hoge ] = <fun>   
*)
let f b = if b then `Hoge else `Fuga;;


(* 
      val hoge : [< `Fuga | `Hoge | `Piyo ] -> string = <fun>   
*)
let hoge = function
  | `Hoge -> "hoge"
  | `Fuga -> "fuga"
  | `Piyo -> "piyo";;


(* ----------------------------------------------------------------------------------------- *)
(* --------------------------------------- [>] 泛型限定 ------------------------------------ *)


(* 
 * 可以接受任何东西的多相变体列表
 类似，泛型限定
 val a : [> `Fuga | `Piyo ] list = [`Fuga; `Piyo]
*)
let  a : [>] list = [`Fuga; `Piyo];;

(* 
  - : [> `Asdf | `Fuga | `Piyo ] list = [`Fuga; `Piyo; `Asdf]   
*)
a @ [`Asdf];;


(* ----------------------------------------------------------------------------------------- *)
(* --------------------------------------- [>] 泛型限定 ------------------------------------ *)


(* `Hoge,`within Fuga *)
(* 
  val f : [< `Fuga | `Hoge ] -> string = <fun>   
*)
let f = function
  | `Hoge -> "hoge"
  | `Fuga -> "fuga";;


(* `Hoge, type within Fuga *)
(* type type_A = [ `Fuga | `Hoge ] *)
type type_A = [`Hoge | `Fuga];;

(* val a : type_A = `Hoge *)
let a : type_A = `Hoge;;

(* - : string = "hoge" *)
f a;;


(* `Hoge,`Fuga or more types *)
(* type type_B = [ `Fuga | `Hoge | `Piyo ] *)
type type_B = [`Hoge | `Fuga | `Piyo];;


(* `I'm Hoge type_B is `Hoge, `Fuga or more types *)
(* val b : type_B = `Hoge *)
let b : type_B = `Hoge;;

(* 
  Error: This expression has type type_B but an expression was expected of type
         [< `Fuga | `Hoge ]
         The second variant type does not allow tag(s) `Piyo   
*)
f b;; (* type error　*)
