(* 

****************************************************************************************************************************************

_ 和 'a 和 (type a) 和 type a. 的区别  【重点】

****************************************************************************************************************************************

*)


(* 
############################################################################################################################
############################################################################################################################
############################################################################################################################


1、_ : 通配符/我不在乎（Wildcard/Don't Care）   这里有一个类型，但我既不知道它是什么，也不需要关心它，而且它每次出现都可以是不同的


############################################################################################################################
############################################################################################################################
############################################################################################################################

*)

(* GADT 形式的  value 类型定义 *)
(* _ 可以是 int 也可以是 bool (不互斥) *)

type _ value =
  | Int : int -> int value    (* Int : 入参类型 int  -> 返回类型 int value, 名曰 该 value 类型 构造子为 Int *)
  | Bool : bool -> bool value (* Bool : 入参类型 bool  -> 返回类型 bool value, 名曰 该 value 类型 构造子为 Bool *)


(* GADT 形式的  expr 类型定义 *)
type _ expr =
  (* Value : 入参类型  -> 返回类型 *)
  | Value : 'a value -> 'a expr              
  | Eq : int expr * int expr -> bool expr
  | Plus : int expr * int expr -> int expr
  | If : bool expr * 'a expr * 'a expr -> 'a expr



(* val i : int -> int expr = <fun> *)
let i x = Value (Int x)


(* 必须用 (type a) 才能让编译器知道返回值的类型会变化 *)
let get_val (type a) (v : a value) : a =
  match v with
  | Int i -> i       (* 编译器推断：此时 a 是 int *)
  | Bool b -> b    (* 编译器推断：此时 a 是 bool *)



(* 每次出现 _ 都是独立的，它们之间没有任何关联： *)

(* 这里的两个 _ 是完全独立的：它们可以是不同的类型 *)
let wrap (x : _) (y : _) = 
  (x, y) 
;;

(* 你可以传入 f 1 "hello"，编译器完全不会报错。
   第一个 _ 可以是 int，第二个 _ 可以是 string，它们互不干涉。 *)
let a = wrap 100 "Hello";; 


(* 这个 报错了，因为 Int 和 Bool 返回的类型是不同的，一个是 int expr，一个是 bool expr *)

(* 'a 要么是 int 要么是 bool 只能是一个 (互斥) *)
type 'a expr =
  | Int : int expr
  | Bool : bool expr    




(* 再如： *)

let wrap_restricted (x : 'a) (y : 'a) = 
  (x, y)
;;

let ok = wrap_restricted 1 2;;      (* ✅ 正常，两个都是 int *)

let error = wrap_restricted 1 "Hi";; (* ❌ 编译报错！ *)
(* 报错原因：第一个 'a 锁定了 int，第二个参数也必须是 int; 它们之间存在 “关联性”  *)

(* 
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

细讲   'a 和 _ 的区别  【重点】 

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
*)



(* 

'a ：通用类型变量（Generic Type Variable）    一个我现在不知道具体是什么，但在整个定义或函数中必须保持一致的类型

_  ：通配符/我不在乎（Wildcard/Don't Care）   这里有一个类型，但我既不知道它是什么，也不需要关心它，而且它每次出现都可以是不同的



'a 是为了类型推断和一致性；_ 是为了忽略类型或声明不一致（仅在 GADT 中）
*)




(* 
############################################################################################################################
############################################################################################################################
############################################################################################################################


2、'a (类型变量 / Type Variable)         一个我目前不知道、但必须保持   一致    的占位符


############################################################################################################################
############################################################################################################################
############################################################################################################################
*)

let pair_up (x : 'a) (y : 'a) = 
  (x, y)
;;

let ok1 = pair_up 10 20;;         (*  ✅  'a 被推断为 int *)
let ok2 = pair_up "Hi" "OCaml";;  (*  ✅  'a 被推断为 string *)

let b = pair_up 1 "Hi";; (* ❌ 编译报错！ *)
(* 报错原因：第一个 'a 锁定了 int，第二个参数也必须是 int; 它们之间存在 “关联性”  *)

(* 又如: *)

(* 定义一个泛型记录类型 'a box *)
type 'a box = {
  contents : 'a;
  label : string;
}

(* 使用方式： *)

(* 类型为 int box *)
let int_box = { contents = 100; label = "数字盒子" }          
(* 类型为 string box *)
let str_box = { contents = "OCaml"; label = "字符串盒子" }    


(* 
############################################################################################################################
############################################################################################################################
############################################################################################################################


3、(type a) (本地抽象类型 / Locally Abstract Type)         在函数内部定义一个真实存在、有名字的临时类型 a


############################################################################################################################
############################################################################################################################
############################################################################################################################
*)

(* module  type *)
module type Bumpable = sig
  type t
  val bump : t -> t
end;;

(* 
  通过类型推断，其类型为 
          sig
            type t
          
            val bump : t -> t
          end 
  目前也就是 module type Bumpable 的 类型
*)
module Int_bumper = struct
  type t = int
  let bump n = n + 1
end;;
(* 
  通过类型推断，其类型为 
          sig
            type t
          
            val bump : t -> t
          end 
  目前也就是 module type Bumpable 的 类型
*)
module Float_bumper = struct
  type t = float
  let bump n = n +. 1.
end;;



let int_bumper = (module Int_bumper : Bumpable with type t = int);;         (* 将 type t 明确为 int， 这时候 first-class module int_bumper 就不是抽象的了 *)

let float_bumper = (module Float_bumper : Bumpable with type t = float);;   (* 将 type t 明确为 float， 这时候 first-class module float_bumper 就不是抽象的了 *)

(* 将第一类模块转换回普通模块，并绑定到一个临时的 Module Bumper 上，并使用点语法访问其内容 *)  
(* 
  模式匹配解包: 
      编译器仍会推断 int_bumper 的具体类型   (目前使用最多的语法，日常首选)
*)
(* let (module Bumper) = ... 这种缩写语法在推断类型时非常依赖上下文 *)
let (module Bumper) = int_bumper in Bumper.bump 3;;  
(* 
  显式解包: 隐式类型推断
      编译器会推断 int_bumper 的具体类型   (不推荐使用)
*)
let module Bumper = (val int_bumper) in Bumper.bump 3;;   
(* 
 显式类型解包: 带类型注解的解包语法
   最安全，最明确，但最冗长，大型项目中使用
*)
let module Bumper = (val int_bumper : Bumpable with type t = int) in Bumper.bump 3;;


let (module Bumper) = float_bumper in Bumper.bump 3.5;;


(* 用到了 【本地抽象类型】  (type a) *)

(* 
    该函数的类型签名为： 
      val bump_list : type a. (module Bumpable with type t = a) -> a list -> a list = <fun>  

      即: (module Bumpable with type t = 'a) -> 'a list -> 'a list
*)
let bump_list  (type a)  (module Bumper : Bumpable with type t = a) (l: a list)  =  List.map Bumper.bump l;;

bump_list int_bumper [1;2;3];;

bump_list float_bumper [1.5;2.5;3.5];;



(* 

用法举例：

*)






(* 
    1、解包第一类模块（最常用场景） 或者 实现通用的“依赖注入”逻辑
*)




module type Comparable = sig
  type t
  val compare : t -> t -> int
end

(* 定义处理整数的比较模块 *)
module Int_cmp = struct
  type t = int
  let compare = Int.compare
end

(* 定义处理字符串的比较模块 *)
module String_cmp = struct
  type t = string
  let compare = String.compare
end


(* 
     函数 find_min 的类型签名为： 
            val find_min : type a. (module Comparable with type t = a) -> a list -> a option = <fun> 

            即: (module Comparable with type t = 'a) -> 'a list -> 'a option
*)
let find_min (type a) (module C : Comparable with type t = a) (lst : a list) =
  (* ... 之前的实现 ... *)
  match lst with
  | [] -> None
  | h :: t -> Some (List.fold_left (fun acc x -> if C.compare x acc < 0 then x else acc) h t)

(* 运行 *)
let result = find_min (module Int_cmp) [3; 1; 4];;
let min_str = find_min (module String_cmp) ["banana"; "apple"]



(* 
    2、处理 GADT（类型精化）
*)

type _ value =
  | Int : int -> int value
  | Bool : bool -> bool value

(* (type a) 允许编译器在分支内部将 a 细化为 int 或 bool *)
let extract_value (type a) (v : a value) : a =
  match v with
  | Int i  -> i  (* 编译器此时知道 a = int *)
  | Bool b -> b  (* 编译器此时知道 a = bool *)

(* 如果这里用 'a，编译器会报错说：i 是 int，但我预期返回 'a *)






(* 

下列的意思是等价的 

*)
(* 1、函子 *)
module Make (M : sig type t val compare : t -> t -> int end) = struct
  let is_equal x y = M.compare x y = 0
end

(* 使用：必须先生成模块 *)
module IntEq = Make(Int)
let res = IntEq.is_equal 1 2

(* 2、使用 【本地抽象类型】  (type a) 来定义函数 *)
let make_is_equal (type a) (compare : a -> a -> int) (x : a) (y : a) =
  compare x y = 0

(* 使用：直接调用函数，类型自动推断 *)
let res = make_is_equal Int.compare 1 2









(* 
############################################################################################################################
############################################################################################################################
############################################################################################################################


4、type a. (显式全称量化 或 显式通用量化 / Explicit Universal Quantification)         我保证这个函数对所有的类型 a 都成立，即使在递归中改变 a 也可以


引入了一个真正的类型名字，又解除了递归调用的类型枷锁
############################################################################################################################
############################################################################################################################
############################################################################################################################
*)

type _ nested =
  | Value : 'a -> 'a nested
  | Wrap  : 'a list nested -> 'a nested 
  (* 注意：Wrap 里面装的是 'a 的列表，类型变了！ *)

(* ❌ 错误的尝试（用普通 'a） *)
let rec count (v : 'a nested) =
  match v with
  | Value _ -> 1
  | Wrap n -> 1 + count n 
  (* 报错！编译器说：第一层你是 'a，第二层你变成了 'a list，
     在普通递归里，类型必须从头到尾保持一致，不准变！ *)


(* ❌ 错误的尝试（用 (type a)） *)
let rec count (type a) (v : a nested) =
  match v with
  | Value _ -> 1
  | Wrap n -> 1 + count n 
  (* 报错！编译器说：第一层你是 a，第二层你变成了 a list，
     在普通递归里，类型必须从头到尾保持一致，不准变！ *)     

(* ✅ 正确的写法（用 type a.） *)
let rec count : type a. a nested -> int = fun v ->
  match v with
  | Value _ -> 1
  | Wrap n -> 1 + count n
  (* 成功！type a. 告诉编译器：这个函数对“任何”类型都成立，
     哪怕在递归时 a 从 int 变成了 int list 也没关系。 *)



     
(* 

type a. 的写法强制你采用 “先写契约，再写实现” 的分离风格

*)

(* 契约部分：显式声明对于所有的 a 成立 *)
let my_func : type a. a list -> int = 
  (* 实现部分 *)
  fun l -> List.length l




(* 

用法举例：

*)




 (* 
    1、让解包和声明更优雅 
*)
module type Showable = sig
  type t
  val to_string : t -> string
end

(* 语法：let 函数名 : type a. (约束) = 实现 *)
let print_anything : type a. (module Showable with type t = a) -> a -> unit =
  fun (module S) x -> print_endline (S.to_string x)


(* 
    2、实现 “多态递归” 
*)

(* 定义一个嵌套容器：可以是单个值，也可以是另一个嵌套容器的列表 *)
type _ nested =
  | Value : 'a -> 'a nested
  | List  : 'a list nested -> 'a nested

(* 如果用普通的 'a，递归调用 depth n 时，编译器会报错：
   因为它认为 a 已经被锁死为第一层的类型，不能变成 a list。 *)

let rec depth : type a. a nested -> int = function
  | Value _ -> 1
  | List n  -> 1 + depth n  (* 这里的 a 变成了 a list！只有 type a. 能办到 *)

(* 测试函数 depth 的正确性 *)
let d = depth (List (List (Value [ [1; 2] ]))) (* 返回 3 *)


(* 
    3、配合 GADT 进行“类型精化”
*)
type _ term =
  | Int  : int -> int term
  | Add  : int term * int term -> int term
  | Is_zero : int term -> bool term
  | If   : bool term * 'a term * 'a term -> 'a term

(* 只有使用 type a.，在 If 分支中，编译器才能证明两个分支返回的 a 是一致的 *)
let rec eval : type a. a term -> a = function
  | Int n -> n
  | Add (x, y) -> (eval x) + (eval y)
  | Is_zero x -> (eval x) = 0
  | If (test, t, e) -> 
      if eval test then eval t else eval e

(* 测试函数 eval *)
(* 1. 计算整数结果   val res_int : int = 3*)
let res_int = eval (Add (Int 1, Int 2)) ;;
(* 2. 计算布尔结果   val res_bool : bool = true*)
let res_bool = eval (Is_zero (Int 0)) ;;
(* 3. 计算复杂的嵌套结果   val res_complex : int = 42 *)
let res_complex = eval (If (Is_zero (Int 0), Int 42, Int 0)) ;;






module type Showable = sig
  type t
  val to_string : t -> string
end

(* 区别 *)

(* 
  先声明，后实现 

  告诉编译器：“我正在定义一个函数，它必须对所有可能的类型 a 都成立”
*)
let print_anything : type a. (module Showable with type t = a) -> a -> unit =
  fun (module S) x -> print_endline (S.to_string x)

(* 
  在定义参数的同时引入类型

  被视为一个特殊的 “类型参数”。它在函数被调用时，由编译器即时创建一个本地类型 a
*)
let print_anything (type a) (module S : Showable with type t = a) (x : a) =
  print_endline (S.to_string x)
  





(* 
  混用例子 
*)
(* 1. 使用 'a: 简单泛型 *)
let head (l : 'a list) = List.hd l

(* 2. 使用 (type a): 解包第一类模块 *)
let bump_int (type a) (module B : Bumpable with type t = a) (x : a) = B.bump x

(* 3. 使用 type a.: 多态递归处理 GADT *)
type _ expr = Int : int -> int expr | List : 'a expr list -> 'a expr list expr
let rec count : type a. a expr -> int = function
  | Int _ -> 1
  | List l -> List.fold_left (fun acc e -> acc + count e) 1 l (* 这里的 a 发生了变化 *)


(* 测试函数 count *)
(* 1. 计算单个整数项  val c1 : int = 1 *)
let c1 = count (Int 42) ;;
(* 2. 计算嵌套列表项  val c2 : int = 5*)
(* 只有 type a. 允许在递归中将 a 从 int 变成 int expr list *)
let c2 = count (List [Int 1; Int 2; Int 3]) ;;


(* 


| 符号      |	官方名称	   |   权力/特性	                | 什么时候用？                          |
|----------|--------------|-----------------------------|--------------------------------------|
| _	       | 通配符	       |  没有任何约束，完全丢弃信息	 | 定义 GADT 的左侧占位，或匹配时忽略某项  |
| 'a	     | 类型变量	     |  靠编译器“猜”，要求全局一致	 | 编写普通的泛型函数 (如 List.length)    |
| (type a) | 本地抽象类型	 |  有名字，能被代码显式引用	   | 解包第一类模块，非递归地处理 GADT       |
| type a.	 | 显式全称量化	 |  支持多态递归，最高证明等级	 | 递归处理 GADT，编写极其严谨的底层库     |


*)