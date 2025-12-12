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


(* 定义一个整数列表 *)
let int_list = [1; 2; 3; 4; 5];;

(* 定义一个字符串列表 *)
let string_list = ["apple"; "banana"; "cherry"];;

(* 定义一个空列表 *)
let empty_list = [];;

(* 错误示例：混合类型会导致编译错误 *)
(* let mixed_list = [1; "two"; 3.0];; *)

(* List 是不可变的链表，适合使用模式匹配和递归操作 *)

(* 如果您确实需要根据索引获取值（注意：这效率不高，因为需要遍历到该位置），可以使用标准库函数 List.nth *)


let int_list = [10; 20; 30; 40; 50];;

(* 获取索引 0 处的值 (第一个元素) *)
let first = List.nth int_list 0;;
(* first 现在是 10 *)

(* 获取索引 3 处的值 (第四个元素) *)
let fourth = List.nth int_list 3;;
(* fourth 现在是 40 *)

(* 索引越界会抛出 Failure("nth") 异常 *)
(* let error = List.nth int_list 10;; *)


(* 使用模式匹配来解构列表 【推荐】 *)

let my_list = [1; 2; 3];;

(* 使用模式匹配提取头部和尾部 *)
match my_list with
| [] -> Printf.printf "列表为空，没有头部和尾部\n"
| head :: tail ->
    Printf.printf "头部是: %d\n" head;
    Printf.printf "尾部是: ";
    List.iter (fun x -> Printf.printf "%d; " x) tail;
    Printf.printf "\n";;


(* 通常在函数定义中使用模式匹配来处理不同情况（空列表 vs 非空列表） *)
let rec get_first_element list =
  match list with
  | [] -> failwith "Cannot get first element of an empty list"
  | head :: tail -> head
  (* 这是一个递归函数，但这里只取了第一个元素 *)

let first_val = get_first_element my_list;;
(* first_val 是 1 *)




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


(* 与数组使用 .( ) 访问不同，元组的元素不能通过索引号（如 0, 1, 2）直接访问。
您必须使用特定的内置函数来提取元素。

fst 和 snd 函数分别用于提取元组中的第一个和第二个元素。

使用 fst 和 snd (仅限 2 元组)
 *)

let coordinate = (10, 20);;

(* 获取第一个元素 *)
let x = fst coordinate;;
(* x 现在是 10 *)

(* 获取第二个元素 *)
let y = snd coordinate;;
(* y 现在是 20 *)

(* 尝试对 多于两个元素的元组使用 fst 或 snd 会导致编译错误 *)
(* let name = fst student_info;; *)

(* 也可以使用模式匹配来提取元组的元素 【推荐】*)

let student_info = (12345, "Alice", 3.8);;

(* 使用模式匹配提取所有值 *)
let (id, name, gpa) = student_info in
Printf.printf "Student ID: %d, Name: %s, GPA: %f\n" id name gpa;

(* 如果您只需要特定的值，可以使用下划线 `_` 忽略不需要的元素 *)
let (_, student_name, _) = student_info in
Printf.printf "The student's name is: %s\n" student_name;



(* 
######################################################################################################################################################
records  记录
######################################################################################################################################################
*)

type point = {x : float; y : float};;   (* 定义 type point = { x : float; y : float; }  其实是起了个别名 point 而不是定义了新的类型 *)
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





(* 当编译器面临歧义：data 的结构同时符合 block 和 tx 的定义。当有多个可能的具名类型别名时，编译器会选择最通用的底层类型，即匿名结构本身 *)
type block = { hash : string };;
type tx = { hash : string };;

(* 默认推断为匿名 record *)
let data = { hash = "xxx" };;

let process_block (b: block) = Printf.printf "Processing block: %s\n" b.hash;;
let process_tx (t: tx) = Printf.printf "Processing tx: %s\n" t.hash;;
let process_data (d: {hash: string}) = Printf.printf "Processing data: %s\n" d.hash;;


let () =
  (* 临时将 data 视为 block 类型传入 【不推荐】 *)
  process_block (data : block);

  (* 临时将 data 视为 tx 类型传入 【不推荐】 *)
  process_tx (data : tx);

  (* 临时将 data 视为匿名记录类型传入 *)
  process_data (data : {hash: string});
;;


let () =
  let data : block = { hash = "xxx" } in (* 添加类型标注 【推荐】 *)
  process_block data;

let () =
  let data : tx = { hash = "xxx" } in (* 添加类型标注 【推荐】 *)
  process_tx data;

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


let f (x : int) = expr        (* arg has constrainted<约束的> type *)


let f : 'a 'b. 'a*'b -> 'a    (* function with constrainted<约束的> *)
      = fun (x,y) -> x        (* polymorphic type *)
   
*)


(* 
######################################################################################################################################################   
模块
######################################################################################################################################################
*)

(* 
module M = struct .. end                  (* module definition 无显示签名 *)

module M: sig .. end = struct .. end      (* module and signature 显示定义签名 【推荐】 *)

module M = Unix                           (* module renaming  重命名 (将 Unix 模块重命名为 M) 起别名 M *)

module M = (Unix : LinuxType);;            (* 将 Unix 模块限制为 LinuxType 类型 (这里的 LinuxType 是未完全覆盖 Unix 成员内容的  module type sig)，并起别名 M (将得到和 Unix 不太一样的模块) *)


include M                                 (* include items from 从别的 Module 中引入 *)


module type OTHER_SIG = sig
  val common_func : string -> unit
  type data_t = int list
end


module OtherModule : OTHER_SIG = struct
  let common_func s = Printf.printf "Common: %s\n" s
  type data_t = int list
end




module MyModule : sig
  (* 使用 include 引入 OTHER_SIG 的所有声明 *)
  include OTHER_SIG

  (* 添加 MyModule 自己的声明 *)
  val foo : int
  val specific_to_mymodule : data_t -> unit
end = struct
  (* 必须提供所有声明的实现 *)
  include OtherModule (* 在实现部分，使用 include Module *)

  let foo = 42

  let specific_to_mymodule d_list =
    Printf.printf "List length: %d\n" (List.length d_list)
end

(* 或者 *)

module type MY_MODULE_SIG = sig
  include OTHER_SIG
  val foo : int
end

module MyModule : MY_MODULE_SIG = struct
  include OtherModule
  let foo = 42
end




module type Sg = sig .. end               (* signature definition *)

module M = (struct ... end : Sg);;        (* module and signature *)
module M : Sg = struct ... end;;          (* module and signature *)





module type Sg = module type of M         (* signature of module *)

 M = struct .. end in ..        (* local module 它被称为局部模块定义或模块约束表达式 ：  它是一种将模块定义限制在特定作用域（Scope）内的语法，类似于 let x = 1 in ... 将变量 x 限制在 in 之后的表达式中一样*)

(* 用法一：局部定义一个临时的辅助模块 A      避免全局污染          在一个大型函数内部使用一个临时的、复杂的辅助模块。使用 let module ... in 可以确保这个辅助模块只在该函数执行期间可见 *)

 let calculate_something input_list =

  (* 局部定义一个临时的辅助模块 A *)
  let module A = struct
    let internal_helper x = x * 2
    let map_list list = List.map internal_helper list
  end in

  (* 在 'in' 后面使用 A 模块 *)
  let intermediate_result = A.map_list input_list in
  
  (* 可以在这里继续使用 A.internal_helper 等 *)
  intermediate_result + 10

(* 在 calculate_something 函数外部，模块 A 是不可见的 *)
(* let result = A.map_list [1; 2];;  <-- 这会导致编译错误 *)


(* 用法二: 结合 Functor 使用（高级用法）              当您使用 Functor（函子，模块工厂）生成一个模块，但又不想给生成的模块起一个全局名字时，这个语法非常方便*)



(* 假设已经定义了 MakeSet Functor *)

let process_data data_list =
  (* 局部生成一个特定于 int 类型的 Set 模块 *)
  let module IntSet = Set.Make(Int) in

  (* 在 in 后面使用 IntSet 模块，例如构建一个集合 *)
  let my_set = IntSet.of_list data_list in

  (* ... 对 my_set 进行操作 ... *)
  IntSet.cardinal my_set (* 返回集合大小 *)
;;



let m = (module M : Sg)                   (* to 1st-class module 【打包】   【将普通模块转换成第一类模块】 (从模块到值) *)
module M = (val m : Sg)                   (* from 1st-class module 【解包】   【将第一类模块转换回普通模块】  (从值到模块) *)


(* 【打包】：  将一个现有的、静态定义的模块 M 封装到一个可以在运行时传递的普通 OCaml 值 m 中 *)

module type ConfigSig = sig
  val block_height : int
end

module CurrentConfig : ConfigSig = struct
  let block_height = 100
end

(* 将 CurrentConfig 模块打包成一个名为 config_value 的值 *)
let config_value : (module ConfigSig) = (module CurrentConfig : ConfigSig);;

(* config_value 现在是一个普通的值，可以传递给函数，如：  get_block_height 函数 *)
let get_block_height config = config.block_height;;

(* 使用 config_value *)
let height = get_block_height config_value;;






(* 【解包】：  获取之前打包好的第一类模块值 m，并将其转换回一个可以在编译时使用的静态模块 M' *)

(* 假设 config_value 是上面打包好的值 *)

(* 在一个新的作用域解包 config_value 为一个名为 LoadedConfig 的静态模块 *)
module LoadedConfig = (val config_value : ConfigSig);;

(* 现在可以使用点语法访问其内容 *)
let height = LoadedConfig.block_height;; (* height 现在是 100 *)

Printf.printf "Loaded height is: %d\n" height;;










module MakeXxx(S: Sg) = struct .. end     (* functor 函子定义 *)
module M = MakeXxx(M')                    (* functor application 函子应用 *)
   
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
   



try ... with  语句块：



try
  expression_that_might_raise_an_exception   (* 可能抛出异常的表达式 *)
with
| Exception_Pattern_1 -> expression_to_handle_1  (* 处理异常的模式匹配 *)
| Exception_Pattern_2 -> expression_to_handle_2  (* 处理异常的模式匹配 *)
| ...
| _ -> expression_to_handle_any_other_exception  (* 处理异常的模式匹配 *)



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