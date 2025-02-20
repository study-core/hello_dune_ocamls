(*
###################################################################################################################################################### 
  开始入门
######################################################################################################################################################  
*)




(* 
************************************************************
      let 绑定不是赋值，它引入了具有新作用域的新标识符
************************************************************  
*)



(* 
  内置基础类型：6 种
  int, float, char, string, and bool, unit
  
  
数据类型	  例子	         解释

int	        1	            有符号整数。在32位系统中长度为31位；在64位系统中长度为63位。
float	      1.	          浮点数。IEEE定义的双精度浮点数，等同于C语言的double。
bool	    true	
char	    'x'	            8 位的字符 (单引号)
string	 "hello"	        (双引号)   "string".[0];;    为 'h' /       let twice s = s ^ s;; 字符串拼接
unit	      ()	          ()是unit类型的唯一的值





又有一说： 


官方教程中提到, int 类型表示与平台相关的有符号整数。这意味着 int 并不总是具有相同的位数。它取决于底层平台特性，例如处理器架构或操作系统。


int 在 32 位架构中有 31 位，在 64 位架构中有 63 位，因为有一个位保留给 OCaml 的运行时操作。

标准库还提供 Int32 和 Int64 模块，它们支持对 32 位和 64 位有符号整数进行独立于平台的操作。



【OCaml 不会在值之间执行任何隐式类型转换。因此，算术表达式不能混合整数和浮点数。参数要么全部为 int ，要么全部为 float 】


unit:             (* void, takes only one value: () *)
int:              (* integer of either 31 or 63 bits, like 42 *)
int32:            (* 32 bits Integer, like 42l *)
int64:            (* 64 bits Integer, like 42L *)
float:            (* double precision float, like 1.0 *)
bool:             (* boolean, takes two values: true or false *)
char:             (* simple ASCII characters, like 'A' *)
string:           (* strings, like "Hello" or foo|Hello|foo *)
bytes:            (* mutable string of chars *)
'a list :         (* lists, like head :: tail or [1;2;3] *)
'a array:         (* arrays, like [|1;2;3|] *)
t1 * ... * tn:    (* tuples, like (1, "foo", 'b') *)


*)


(* 类型： -:int *)
32  

(* val x : int = 42 *)
let x = 42;;



(* 
X 类型转换为 Y 类型的函数的命名规则为 Y_of_X   
*)
(* 
  - : int = 123   
*)
int_of_string "123";;

(* 
  val a : int = 1
  val b : int = 2    
*)
let a = 1 and b = 2;;



(* 
######################################################################################################################################################
数组      语法： [| element; element; ... |]
######################################################################################################################################################
*)

(* 
数组 val arr : int array = [|1; 2; 3|]   
*)
let arr = [|1; 2; 3|];;

(* 
- : int = 1   
*)
arr.(0);;

(* 
- : unit = ()   
*)
arr.(0) <- 0;;

(* 
- : int array = [|0; 2; 3|]   
*)
arr;;

(* 
val a : int array = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0|]   
*)
let a = Array.make 10 0;;



(* 
######################################################################################################################################################
List
######################################################################################################################################################
*)

[];;  (* - : 'a list = [] *)

[1; 2; 3];; (* - : int list = [1; 2; 3] *)

[[1; 2]; [3; 4]; [5; 6]];;  (* - : int list list = [[1; 2]; [3; 4]; [5; 6]] *)

[false; true; false];;  (* - : bool list = [false; true; false] *)


(* 
######################################################################################################################################################
元组 
######################################################################################################################################################
*)

(* - : int * int = (1, 2) *)
(1, 2);;

(* 
  - : char * int * string * float = ('a', 1, "str", 4.3)   
*)
('a', 1, "str", 4.3);;

(* 
  - : (int * int) * (char * string) = ((1, 2), ('a', "str"))   
*)
((1, 2), ('a', "str"));;



(* 
######################################################################################################################################################
records  记录
######################################################################################################################################################
*)

type point = {x : float; y : float};;   (* 定义 type point = { x : float; y : float; } *)
let a = {x = 5.0; y = 6.5};;  (* 实例化 val a : point = {x = 5.; y = 6.5} *)


(* 
type colour = {
  websafe : bool;
  r : float;
  g : float;
  b : float;
  name : string;
}   
*)
type colour = {websafe : bool; r : float; g : float; b : float; name : string};;
let b = {websafe = true; r = 0.0; g = 0.45; b = 0.73; name = "french blue"};;  (* val b : colour = {websafe = true; r = 0.; g = 0.45; b = 0.73; name = "french blue"}  【对的】*)
(* let c = {name = "puce"};;  【错的定义】, 因为 records 必须包含所有 field *)



(* Records may be mutable: *)
type person =
  {first_name : string;
   surname : string;
   mutable age : int};;   (* type person = { first_name : string; surname : string; mutable age : int; } *)

let birthday p =
  p.age <- p.age + 1;;  (* 修改字段的值, val birthday : person -> unit = <fun> *)



(* 类型 *)
type record =               (* new record type *)
{ field1 : bool;            (* immutable field *)
  mutable field2 : int; }   (* mutable field *)

type enum =                 (* new variant(变体) type *)
  | Constant                (* Constant constructor *)
  | Param of string         (* Constructor with arg*)
  | Pair of string * int    (* Constructor with args *)
  | Gadt : int -> enum      (* GADT constructor *)
  | Inlined of { x : int }  (* Inline record *)  
(* 值 *)

let r = { field1 = true; field2 = 3; };;
let r' = { r with field1 = false };;   (* 表示使用 r 的各个字段初始化 r'，但是 field1 字段设置为 false *)
r.field2 <- r.field2 + 1 ;;
let c = Constant;;
let c = Param "foo";;
let c = Pair ("bar",3);;
let c = Gadt 0;;
let c = Inlined { x = 3 };;


(* 
######################################################################################################################################################
引用、字符串、数组 
######################################################################################################################################################  
*)

let x = ref 3;;   (* integer reference (mutable) *)
x := 4 ;;         (* reference assignation *)
print_int !x;;  (* reference access *)
(* 
s.[0]  ;;         (* string char access *)
t.(0)  ;;         (* array element access *)
t.(0) <- x ;;     (* array element modification *)   
*)


(* 
######################################################################################################################################################
引入命名空间   
######################################################################################################################################################
*)

(* 
open Unix               (* global open *)
let open Unix in expr   (* local open *)
Unix.(expr)             (* local open *)   
*)


(* 
######################################################################################################################################################
函数
######################################################################################################################################################
*)

(* 

let f x = expr                (* function with one arg *)
let rec f x = expr            (* recursive function, apply: f x *)
let f x y = expr              (* with two args, apply: f x y *)
let f (x,y) = expr            (* with a pair as arg, apply: f (x,y) *)
List.iter (fun x -> expr)     (* anonymous function *)
let f = function None -> act  (* function definition *)
      | Some x -> act         (* function definition [by cases] *)
                              (* apply: f (Some x) *)
let f ~str ~len = expr        (* with labeled args *)
                              (* apply: f ~str:s ~len:10 *)
                              (* apply: (for ~str:str):  f ~str ~len *)
let f ?len ~str = expr        (* with optional arg (option) *)
let f ?(len=0) ~str = expr    (* optional arg default *)
                              (* apply (with omitted arg): f ~str:s *)
                              (* apply (with commuting): f ~str:s ~len:12 *)
                              (* apply (len: int option): f ?len ~str:s *)
                              (* apply (explicitly omitted): f ?len:None ~str:s *)
let f (x : int) = expr        (* arg has constrainted type *)
let f : 'a 'b. 'a*'b -> 'a    (* function with constrainted *)
      = fun (x,y) -> x        (* polymorphic type *)
   
*)


(* 
######################################################################################################################################################   
模块
######################################################################################################################################################
*)

(* 
module M = struct .. end                  (* module definition *)

module M: sig .. end = struct .. end      (* module and signature *)

module M = Unix                           (* module renaming *)

module M = (Unix : LinuxType);;            (* 将 Unix 模块限制为 LinuxType 类型 (这里的 LinuxType 是未完全覆盖 Unix 成员内容的  module type sig)，并起别名 M (将得到和 Unix 不太一样的模块) *)

(* 写在 module xxx = struct 定义之内, 我觉得 *)
include M                                 (* include items from *)

module type Sg = sig .. end               (* signature definition *)

module M = (struct ... end : Sg);;        (* module and signature *)
module M : Sg = struct ... end;;          (* module and signature *)

module type Sg = module type of M         (* signature of module *)

let module M = struct .. end in ..        (* local module *)

let m = (module M : Sg)                   (* to 1st-class module *)
module M = (val m : Sg)                   (* from 1st-class module *)

module MakeXxx(S: Sg) = struct .. end     (* functor *)
module M = MakeXxx(M')                    (* functor application *)
   
*)



(* 
######################################################################################################################################################
模式匹配
######################################################################################################################################################
*)

(* 

match expr with
  | pattern -> action
  | pattern when guard -> action    (* conditional case *)
  | _ -> action                     (* default case *)


Patterns:
  | Pair (x,y) ->                   (* variant pattern *)
  | { field = 3; _ } ->             (* record pattern *)
  | head :: tail ->                 (* list pattern *)
  | [1;2;x] ->                      (* list pattern *)
  | (Some x) as y ->                (* with extra binding *)
  | (1,x) | (x,0) ->                (* or-pattern *)
  | exception exn ->                (* try&match *)
   
*)


(* 
######################################################################################################################################################
条件语句
######################################################################################################################################################
*)

(* 

x = y           (* (Structural) Polymorphic Equality *)             结构    相等
x == y          (* (Physical) Polymorphic Inequality *)             物理    相等
x <> y          (* (Structural) Polymorphic Equality *)             结构    不相等   (值)
x != y          (* (Physical) Polymorphic Inequality *)             物理    不相等   (地址)
compare x y     (* negative, when x < y *)
compare x y     (* 0, when x = y *)
compare x y     (* positive, when x > y *)   

*)

(* 
######################################################################################################################################################   
循环语句
######################################################################################################################################################
*)


(* 

[while] cond [do] ... [done];
[for] var = min_value [to] max_value [do] ... [done];
[for] var = max_value [downto] min_value [do] ... [done];
   
*)


(* 
######################################################################################################################################################
异常
######################################################################################################################################################
*)

(* 

exception MyExn                 (* new exception *)
exception MyExn of t * t'       (* same with arguments  *)
exception MyFail = Failure      (* rename exception with args *)
raise MyExn                     (* raise an exception *)
raise (MyExn (args))            (* raise with args *)
try expr                        (* catch MyExn *)
with MyExn -> ...               (* if raised in expr *)
   
*)


(* 
######################################################################################################################################################
对象和类
######################################################################################################################################################
*)

class virtual foo x =           (* virtual class with arg 抽象类 *)
  let y = x+2 in                (* init before object creation *)
  object (self: 'a)             (* object with self reference *)
  val mutable variable = x      (* mutable instance variable *)
  method get = variable         (* accessor *)
  method set z =
    variable <- z+y             (* mutator *)
  method virtual copy : 'a      (* virtual method *)
  initializer                   (* init after object creation *)
    self#set (self#get+1)
end

class bar =                     (* non-virtual class *)
  let var = 42 in               (* class variable *)
  fun z -> object               (* constructor argument *)
  inherit foo z as super        (* inheritance and ancestor reference  继承*)
  method! set y =               (* method explicitly overridden *)
    super#set (y+4)             (* access to ancestor *)
  method copy = {< x = 5 >}     (* copy with change *)
end
let obj = new bar 3 ;;            (* new object *)
obj#set 4; obj#get              (* method invocation *)
(* let obj = object .. end         (* immediate object *) *)


(* 
######################################################################################################################################################
多态变体
######################################################################################################################################################
*)

(* 

type t = [ `A | `B of int ]       (* closed variant *)

type u = [ `A | `C of float ]

type v = [ t | u | ]              (* union of variants *)

let f : [< t ] -> int = function  (* argument must be a subtype of t *)
  | `A -> 0 | `B n -> n

let f : [> t ] -> int = function  (* t is subtype of the argument *)
  |`A -> 0 | `B n -> n | _ -> 1
   
*)




(* 使用  _  代替泛型 *)
let give_me_a_three _ = 3;;  (* val give_me_a_three : 'a -> int = <fun> *)


(* 
give_me_a_three (1 / 0);;
Exception: Division_by_zero.   
*)


(* 
######################################################################################################################################################   
惰性求值
######################################################################################################################################################
*)


let lazy_expr = lazy (1 / 0);;  (* val lazy_expr : int lazy_t = <lazy> *)


give_me_a_three lazy_expr;;  (* - : int = 3 *)

(* 强行求惰性表达式的值时，用 Lazy.force 函数 *)

Lazy.force lazy_expr;;   (* Exception: Division_by_zero. *)

















{|This is a quoted string, here, neither \ nor " are special characters|} ;;     (* val - : string ,  注意  [| |] 才表示 数组 *)


{|"\\"|}="\"\\\\\"";;  (* true *)


{delimiter|the end of this|}quoted string is here|delimiter} = "the end of this|}quoted string is here";;  (* true *)




(* 

在 stdlib.ml 中定义了  反向运算符


external ( |> ) : 'a -> ('a -> 'b) -> 'b = "%revapply"
external ( @@ ) : ('a -> 'b) -> 'a -> 'b = "%apply"

*)
(@@);;   (* - : ('a -> 'b) -> 'a -> 'b = <fun> *)