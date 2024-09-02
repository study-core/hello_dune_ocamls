type colour = Red | Green | Blue | Yellow;;

(* val additive_primaries : colour * colour * colour = (Red, Green, Blue) *)
let additive_primaries = (Red, Green, Blue);;


(* val pattern : (int * colour) list = [(1, Red); (3, Green); (1, Red); (2, Green)] *)
let pattern = [(1, Red); (3, Green); (1, Red); (2, Green)];;

(* 
######################################################################################################################################################
注意下列两种 函数写法区别 
######################################################################################################################################################  
*)
(* val example : colour -> string = <fun> *)
let example c =
  match c with
  | Red -> "rose"
  | Green -> "grass"
  | Blue -> "sky"
  | Yellow -> "banana";;
(* 等价上面的 *)
let example = function
  | Red -> "rose"
  | Green -> "grass"
  | Blue -> "sky"
  | Yellow -> "banana";;







(* val is_primary : colour -> bool = <fun> *)
let rec is_primary = function
  | Red | Green | Blue -> true
  | _ -> false;;


(* 
type colour2 =
    Red
  | Green
  | Blue
  | Yellow
  | RGB of float * float * float
  | Mix of float * colour2 * colour2     
*)
type colour2 =
  | Red
  | Green
  | Blue
  | Yellow
  | RGB of float * float * float
  | Mix of float * colour2 * colour2;;



(* val rgb_of_colour : colour2 -> float * float * float = <fun> *)
let rec rgb_of_colour = function
  | Red -> (1.0, 0.0, 0.0)
  | Green -> (0.0, 1.0, 0.0)
  | Blue -> (0.0, 0.0, 1.0)
  | Yellow -> (1.0, 1.0, 0.0)
  | RGB (r, g, b) -> (r, g, b)
  | Mix (p, a, b) ->
      let (r1, g1, b1) = rgb_of_colour a in
      let (r2, g2, b2) = rgb_of_colour b in
      let mix x y = x *. p +. y *. (1.0 -. p) in
        (mix r1 r2, mix g1 g2, mix b1 b2);;


(* type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree， 这里的 'a 表示泛型 *)
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree;;        

(* val t : int tree = Node (Node (Leaf, 1, Leaf), 2, Node (Node (Leaf, 3, Leaf), 4, Leaf)) *)
(* 这里将 'a 实例为 int， 所以 'a tree 就是  int tree 类型的值 *)
let t = Node (Node (Leaf, 1, Leaf), 2, Node (Node (Leaf, 3, Leaf), 4, Leaf));;  


(* val total : int tree -> int = <fun> *)
let rec total = function
  | Leaf -> 0
  | Node (l, x, r) -> total l + x + total r;;

let all = total t;;  (* val all : int = 10  求 t 这棵树的各个支点数值的和 *)

 
(* val flip : 'a tree -> 'a tree = <fun>   *)
let rec flip = function
  | Leaf -> Leaf
  | Node (l, x, r) -> Node (flip r, x, flip l);;
  
(* val flipped : int tree = Node (Node (Leaf, 4, Node (Leaf, 3, Leaf)), 2, Node (Leaf, 1, Leaf)) *)
let flipped = flip t;;

t = flip flipped;;  (*  - : bool = true   *)

(* val insert : 'a * 'b -> ('a * 'b) tree -> ('a * 'b) tree = <fun> *)
let rec insert (k, v) = function
  | Leaf -> Node (Leaf, (k, v), Leaf)
  | Node (l, (k', v'), r) ->
      if k < k' then Node (insert (k, v) l, (k', v'), r)
      else if k > k' then Node (l, (k', v'), insert (k, v) r)
      else Node (l, (k, v), r);;



      



type 'a option = None | Some of 'a ;;    

Some 42;; (* - : int option = Some 42 *)

(* 
######################################################################################################################################################
使用模式匹配可以定义函数:
######################################################################################################################################################

让用户轻松处理选项值。

下面是类型为（'a -> 'b) -> 'a option -> 'b option 的 map 函数定义。如果存在选项值 Some v，它允许我们对封装在选项中的值 v 应用到函数 f 

*)

(* 
********************************************************************
********************************************************************
********************************************************************
********************************************************************   
val map : ('a -> 'b) -> 'a option -> 'b option = <fun>  
********************************************************************
********************************************************************
********************************************************************
********************************************************************
*)  
(* map 接受两个参数：要应用的函数 f 和一个选项值 o, 如果 o 是 Some v，则 map f o 返回 Some (f v)；如果 o 是 None，则 map f o 返回 None *)
(* 其中 f 是个函数 'a -> 'b  则 map 的参数为 'a -> 'b 和 'a opion  返参为 'b option 关于这点主要看 Some (f v) 推断出来 ，因为 'a 就是 v, 而 'b 就是  f(v) 的返回值 *)
let map f = function
  | None -> None
  | Some v -> Some (f v);;





(* 
********************************************************************
********************************************************************
********************************************************************
********************************************************************   
val join : 'a option option -> 'a option = <fun>  
********************************************************************
********************************************************************
********************************************************************
********************************************************************
*)
(* 看 Some Some v -> Some v 可以推断出  join 的入参为 'a option option， 返参为 'a option  *)
let join = function
  | Some Some v -> Some v
  | Some None -> None
  | None -> None;;





(* val get : 'a option -> 'a = <fun>   *)
let get = function
  | Some v -> v
  | None -> raise (Invalid_argument "option is None");;




(* 建议使用 value 函数，而不建议使用 get 函数 *)
(* val value : 'a -> 'a option -> 'a = <fun> *)
let value default = function
  | Some v -> v
  | None -> default;;


(* 
********************************************************************
********************************************************************
********************************************************************
********************************************************************   
val fold : ('a -> 'b) -> 'b -> 'a option -> 'b = <fun> 
********************************************************************
********************************************************************
********************************************************************
********************************************************************
*)
(* 先将 o 管道给 map 函数得到  'b option *)
(* 再将 'b option 管道给 value 函数得到 'b, 【注意】 value 函数的入参返参为: 'b -> 'b option -> 'b *)
(* 又函数 f 入参和返参为 'a -> 'b  *)
(* 所以整个类型推断为入参：('a -> 'b) 和 'b 和 'a option 返参为 'b *)
let fold f default o = o |> map f |> value default;;

(* 
********************************************************************
********************************************************************
********************************************************************
********************************************************************   
val unfold : ('a -> bool) -> ('a -> 'b) -> 'a -> 'b option = <fun> 
********************************************************************
********************************************************************
********************************************************************
********************************************************************
*)

(* 可知 p x 是 ('a -> bool)  而  f x 是 ('a -> 'b) *)
(* 所以unfold函数入参为： ('a -> bool) 和 ('a -> 'b) 和 'a 返参为： 'b option  *)
let unfold p f x =
  if p x then
    Some (f x)
  else
    None;;






(* 
********************************************************************   
当使用 and 声明时，数据类型可以  【相互递归】：
********************************************************************
*)
type t = A | B of t' and t' = C | D of t   

type t' = Int of int | Add of t * t
  and t = {annotation : string; data : t'}


(* 
相互引用的 函数

  val sum_t' : t' -> int = <fun>
  val sum_t : t -> int = <fun>     
*)
let rec sum_t' = function
  | Int i -> i
  | Add (i, i') -> sum_t i + sum_t i'
  and sum_t {annotation; data} =
    if annotation <> "" then Printf.printf "Touching %s\n" annotation;
    sum_t' data;;





(* 
float * float * float 的 RGB 与 (float * float * float) 的 RGB 是有区别的

前者是一个带有三个相关数据的构造函数

后者是一个带有一个元组的构造函数

这有两个方面的关系：

二者的内存布局不同 (元组是一个额外的间接)

以及使用元组创建或匹配的能力不同

如：
*)

(* type t = T of int * int *)
type t = T of int * int;;


(* type t2 = T2 of (int * int) *)
type t2 = T2 of (int * int);;


(* 使用 *)
let pair = (1, 2);;  (* val pair : int * int = (1, 2) *)

(* 
T pair;;

Error: The constructor T expects 2 argument(s),
       but is applied here to 1 argument(s)   
*)

T2 pair;;  (* - : t2 = T2 (1, 2) *)


