(* 
****************************************************************************************************************************************
****************************************************************************************************************************************
****************************************************************************************************************************************


GADT     (广义代数数据类型)      和认知中的 OCaml 语法不一样


****************************************************************************************************************************************
****************************************************************************************************************************************
****************************************************************************************************************************************

广义代数数据类型（简称 GADT）是 变体的扩展。 

GADT 比常规变体更具表现力，这可以帮助您创建更精确地匹配您要编写的程序形状的类型。

这可以帮助您编写更安全、更简洁、更高效的代码。

*)


(* 

这里的语法需要一些解码。

每个标签   [右侧的冒号]  告诉您这是一个 GADT。

在冒号的右侧，您会看到 看起来像普通的  单参数函数类型，您几乎可以这样想；

具体来说，作为 该特定标记的 【类型签名】，被视为类型构造函数。

箭头 -> 的 

左侧 表示 构造函数的参数类型，
右侧 确定 构造值的类型。







在 GADT 中每个标签的定义中，箭头  右侧  是整个 GADT 类型的实例，每种情况下类型参数都有独立的选择。

重要的是，类型参数可以取决于 标签和参数的类型。


Eq 是一个类型参数完全由标签确定的示例：它始终对应于 bool expr 。 

If 是一个示例，其中类型参数取决于标记的参数，特别是 If 的类型参数是 then 和 else 子句的类型参数。

*)

(* GADT 形式的  value 类型定义 *)
type _ value =
  | Int : int -> int value    (* Int : 入参类型 int  -> 返回类型 int value *)
  | Bool : bool -> bool value (* Bool : 入参类型 bool  -> 返回类型 bool value *)


(* GADT 形式的  expr 类型定义 *)
type _ expr =
  | Value : 'a value -> 'a expr              (* Value : 入参类型  -> 返回类型 *)
  | Eq : int expr * int expr -> bool expr
  | Plus : int expr * int expr -> int expr
  | If : bool expr * 'a expr * 'a expr -> 'a expr



(* val i : int -> int expr = <fun> *)
let i x = Value (Int x)

(* val b : bool -> bool expr = <fun> *)
and b x = Value (Bool x)

(* val ( +: ) : int expr -> int expr -> int expr = <fun> *)
and (+:) x y = Plus (x,y);;


(* - : int expr = Value (Int 3) *)
i 3;;

b 3;;
(* 
Line 1, characters 3-4:
Error: This expression has type int but an expression was expected of type bool 
*)

(* - : int expr = Plus (Value (Int 3), Value (Int 6)) *)
i 3 +: i 6;;

i 3 +: b false;;
(* 
Line 1, characters 8-15:
Error: This expression has type bool expr
       but an expression was expected of type int expr
       Type bool is not compatible with type int   
*)





(* 

这些类型安全规则不仅适用于构造表达式，还适用于解构表达式。

这意味着我们可以编写一个更简单、更简洁的求值器，不需要任何类型安全检查。


但是 GADT 缺点： 


GADT 的缺点之一，即使用它们的代码需要额外的类型注释。

*)


(* 
  函数  eval_value (入参类型  a. a value)  -> (返参类型  a) 

  val eval_value : 'a value -> 'a = <fun>

  函数  eval_value 定义(去使用 GADT  类型  value 时)需要加 类型注释  type a. a value -> a
*)
let eval_value : type a. a value -> a = function
  | Int x -> x
  | Bool x -> x;;


(* 多态 eval 函数 *)
(* val eval : 'a expr -> 'a = <fun> *)
(* 同理，也要加  类型注释 *)
let rec eval : type a. a expr -> a = function
  | Value v -> eval_value v
  | If (c, t, e) -> if eval c then eval t else eval e
  | Eq (x, y) -> eval x = eval y
  | Plus (x, y) -> eval x + eval y;;




(* 不加 类型注释  就会报错  *)

let eval_value = function
  | Int x -> x
  | Bool x -> x;;
(* 
Error: This pattern matches values of type bool value
       but a pattern was expected which matches values of type int value
       Type bool is not compatible with type int   
*)

(* 
OCaml 默认情况下不愿意在同一函数体内以不同的方式实例化普通类型变量，而这正是这里所需要的。

即： type a. a value -> a  中的 a.

我们可以通过添加【本地抽象类型】来解决这个问题。



*)
let eval_value (type a) (v : a value) : a =
  match v with
  | Int x -> x
  | Bool x -> x;;

(* 
   但是在 eval 函数中 对 type a. a expr -> a 添加 [本地抽象类型] 报错
*)
let rec eval (type a) (e : a expr) : a =
  match e with
  | Value v -> eval_value v
  | If (c, t, e) -> if eval c then eval t else eval e
  | Eq (x, y) -> eval x = eval y
  | Plus (x, y) -> eval x + eval y;;
(* 
Error: This expression has type a expr but an expression was expected of type
         bool expr
       Type a is not compatible with type bool   
*)


