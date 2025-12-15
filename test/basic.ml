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
对象和类  (不是重点，略过)
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
  (* 构造函数参数 *)
  fun z -> object               (* constructor argument *)
  (* 继承 foo 类，并引用父类的方法 *)
  inherit foo z as super        (* inheritance and ancestor reference  继承*)

  (* 重写父类的方法 *)
  method! set y =               (* method explicitly overridden *)
    super#set (y+4)             (* access to ancestor *)
  
  (* 复制对象并修改其属性 *)
  method copy = {< x = 5 >}     (* copy with change *)
end


let obj = new bar 3 ;;          (* new object *)

obj#set 4; obj#get              (* method invocation *)
(* let obj = object .. end      (* immediate object *) *)


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


(* 

对于 ADT 中的 标准变体 来说他们是  关闭的 Closed Variant

即： 他们只能包含他们定义时指定的标签，不能包含其他标签


type food =
  | Pizza
  | Salad
  | Pasta of string (* 意大利面可以指定酱料 *)

对于 food 类型, 你只能点这三样。不能点“寿司”





对于 多态变体来说     不需要在使用它们之前声明它们的类型   type xxx = ，而是直接写

编译器会根据你使用的标签自动推断出一个多态变体类型

(* 无需 type food_label = ... *)

let order1 = `Pizza
let order2 = `Sushi  (* 随时可以添加新的标签 *)



多态变体的用途：

1、轻量级标签和消息

当你需要一个简单的标签，但又不想创建一个正式的 type 定义来污染命名空间时

2、 模拟结构化类型

先看 标准变体 的做法，再看 使用 多态变体 怎么实现结构化

module M1 = struct
  type status = Active | Inactive    (* M1 使用了 标准变体 *)
  let get_status = Active            (* 编译器推断 get_status 的类型是 M1.status 而不是 类型 status = Active | Inactive *)
end

module M2 = struct
  type status = Active | Inactive    (* M2 使用了 标准变体 *)
  let get_status = Inactive          (* 编译器推断 get_status 的类型是 M2.status 而不是 类型 status = Active | Inactive *)
end

(* 尝试写一个通用函数来处理任何状态 *)
let handle_status s =
  match s with
  | Active -> print_endline "Active"
  | Inactive -> print_endline "Inactive"


这时候执行:


handle_status M1.get_status：可以运行。 
handle_status M2.get_status：编译错误！

因为： 编译器会选择它   首先遇到    的或当  前作用域中最容易   访问的那个类型
      很明显应该选择 M1.status 而不是 M2.status (所以 handle_status M2.get_status：编译错误！)
      当编译器选择了 M1.status 之后，它就无法再选择 M2.status 了，因为 M2.status 的类型不一致。


为什么？ 对于 handle_status 来说， M1.get_status 和 M2.get_status 的类型不一致

handle_status M1.get_status：M1.get_status 的类型是 M1.status
handle_status M2.get_status：M2.get_status 的类型是 M2.status

而 M1.status 和 M2.status 的类型不一致，所以编译错误。 因为 M1.status 和 M2.status 是两个不同名称的类型


下面来看 使用 多态变体 怎么实现结构化


module M1 = struct
  let get_status = `Active (* 使用标签 *)
end

module M2 = struct
  let get_status = `Inactive (* 使用标签 *)
end

(* 尝试写一个通用函数来处理任何状态 *)
let handle_status s =
  match s with
  | `Active -> print_endline "Active"
  | `Inactive -> print_endline "Inactive"
  | _ -> () (* 开放性需要通配符 *)


这时候执行:

handle_status M1.get_status：可以运行。
handle_status M2.get_status：可以运行。

结构化体现在：handle_status 函数不关心 M1.get_status 和 M2.get_status 来自哪里，或者它们的完整类型叫什么名字。
它只检查一个东西：它们的内部结构是否包含 `Active 或 `Inactive 标签？ (编译器将自动推断出它们的类型是 [> `Active | `Inactive ])


(* 这个函数接受    任何包含 `Red 或 `Green 标签的类型  -----  只要某类型包含了 `Red 或 `Green 标签，它就可以被这个函数处理 *)
let check_status (s : [ `Red | `Green ]) =
  match s with
  | `Red -> true
  | `Green -> false


3、实现鸭子类型（Duck Typing）

先来 标准变体

type animal = Dog | Duck | Cat (* 封闭集合 *)

let speak = function
  | Dog -> "Woof"
  | Duck -> "Quack"
  | Cat -> "Meow"

但是对于多态变体来说，我们可以这样做：

不要写 type animal = [ `Dog | `Duck | `Cat ]，编译器会自动推算出来 (显示的写出来也没问题)

let speak = function
  | `Dog -> "Woof"
  | `Duck -> "Quack"
  | `Cat -> "Meow"



4、类继承的替代



先看 class 做法

(* OCaml 中的 OOP 示例，非主流风格 *)
class virtual shape = object
  method virtual area : float
end

class circle radius = object
  inherit shape
  val radius = radius
  method area = Pervasives.pi *. radius *. radius
end

class rectangle w h = object
  inherit shape
  val width = w
  val height = h
  method area = width *. height
end


(* 这是一个列表，列表中的元素是 shape 类型，列表中的元素是 circle 类型和 rectangle 类型 *)
let shapes = [ (new circle 2.0 : shape); (new rectangle 3.0 4.0 : shape) ]
(* 计算总面积 *)
let total_area = List.fold_left (fun acc s -> acc +. s#area) 0.0 shapes



标准变体的做法

(* 定义一个 shape 类型，它是一个标准变体，它包含了 Circle 和 Rectangle 两个标签 *)
type shape =
  | Circle of float
  | Rectangle of float * float
  (* 如果要添加三角形，在这里修改 *)

(* 计算面积 *)
let area = function
  | Circle r -> Pervasives.pi *. r *. r
  | Rectangle (w, h) -> w *. h


与继承的对比：
实现多态： area 函数通过模式匹配处理多种数据“形态”，实现了类似多态的效果。
添加新操作更容易： 如果想添加 perimeter 函数，只需添加一个新的函数，而无需修改 type shape 定义。
添加新变体更难： 如果想添加 Triangle，需要修改 type shape 以及 area 函数 以及 perimeter 函数。


多态变体的做法


(* 绘制函数只关心绘制相关的标签 *)
let draw = function
  | `Circle (x, y, r) -> Printf.printf "Draw circle...\n"
  | `Rect   (x, y, w, h) -> Printf.printf "Draw rect...\n"
  | _ -> print_endline "Unknown draw command"

(* 移动函数只关心移动相关的标签 *)
let move = function
  | `Move_by (dx, dy) -> print_endline "Moving..."
  | _ -> ()


又有一个 Shape 抽象基类，Circle 和 Rectangle 继承它，并覆盖 draw() 方法。你需要管理对象的状态

(* 1. 定义一个通用的消息类型 (Message Type)，这取代了类继承体系 *)
type render_msg =
  | `Draw_circle of float * float * float  (* x, y, radius *)
  | `Draw_rect   of float * float * float * float (* x, y, w, h *)
  | `Set_color   of string


这比 类继承 更灵活，因为你可以随时添加新的消息（比如 Clear_screen ），而无需修改现有的  “类”

*)


(* 使用通配符 _ 来捕获所有未明确列出的多态变体标签 *)
let process_colour colour =
  match colour with
  | `Red -> "Stop"
  | `Green -> "Go"
  | _ -> "Other status" (* 捕获 `Blue`, `Yellow` 或任何其他标签 *)



(* 
多态变体的限定


(* 这是一个函数签名，这个函数可以接受任何类型，只要它至少包含 Green和 Red 这两个标签 *)
val check_status : [> `Green | `Red ] -> bool = <fun>



您展示了多态变体如何实现比标准变体更精细的类型控制：
[< T ]：要求输入必须少于或等于 T 的标签（封闭，编译器检查所有情况）。
[> T ]：要求输入必须多于或等于 T 的标签（开放，需要 _ 来处理未知情况）。


(* 
  只能处理 t 或比 t 更少的标签； 
  必须是 t 类型的子集； 接受t的子类型（即标签比t少或等于t的类型）作为输入
  只能传入 [A] 或 [B] 或 [A | B], 不能传入 [C] 
*)
let f : [< t ] -> int = function 
  | `A -> 0 
  | `B -> 1
  (* 编译器知道只有这两个可能，不需要 _ *)


(* 
  必须至少能处理 t 包含的所有标签，但可以处理更多； 
  必须包含 t 所有的标签（ A和 B），但可以有更多； 接受t的超类型（即标签比t多或等于t的类型）作为输入
  可以传入 t 类型，也可以传入 v 类型（t 和 u 的组合，包含 A, B, C），因为 v 包含了 t 的所有标签 
*)
let f : [> t ] -> int = function 
  | `A -> 0 
  | `B -> 1 
  | _ -> 2 (* 需要 _ 来捕获 `C` 或其他未知的标签 *)

*)


(* 
######################################################################################################################################################   
惰性求值
######################################################################################################################################################
*)


(* 使用  _  代替泛型 *)
let give_me_a_three _ = 3;;  (* val give_me_a_three : 'a -> int = <fun> *)


(* 
give_me_a_three (1 / 0);;
Exception: Division_by_zero.   
*)

let lazy_expr = lazy (1 / 0);;  (* val lazy_expr : int lazy_t = <lazy> *)


give_me_a_three lazy_expr;;  (* - : int = 3 *)

(* 强行求惰性表达式的值时，用 Lazy.force 函数 *)

Lazy.force lazy_expr;;   (* Exception: Division_by_zero. *)

















{|This is a quoted string, here, neither \ nor " are special characters|} ;;     (* val - : string ,  注意  [| |] 才表示 数组 *)


{|"\\"|}="\"\\\\\"";;  (* true *)


{delimiter|the end of this|}quoted string is here|delimiter} = "the end of this|}quoted string is here";;  (* true *)




(* 

在 stdlib.ml 中定义了  反向运算符 : 即 |> 和 @@  运算符


external ( |> ) : 'a -> ('a -> 'b) -> 'b = "%revapply"
external ( @@ ) : ('a -> 'b) -> 'a -> 'b = "%apply"

*)

(* 它接收左侧的值 x，然后将其作为参数传递给右侧的函数 f *)
10 |> (fun x -> x + 1) ;;   (* - : int = 11 *)

(* 它接收右侧的值 x，然后将其作为参数传递给左侧的函数 f *)
(fun x -> x + 1) @@ 10 ;;   (* - : int = 11 *)
