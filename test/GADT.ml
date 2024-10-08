(* 
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################


GADT     (广义 代数 数据 类型)      和认知中的 OCaml 语法不一样



如: 使用    _ elem       代替     'a elem

######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################







【代数数据类型 (ADT) 是一种可以用来对应用状态进行建模的好方法，我们可以把它看作是  【进阶版的 枚举】。我们指定类型可以组成的潜在子类型，以及构造函数参数：】


type shape =

   | Square(int)

   | Rectangle(int, int)

   | Circle(int);







广义代数数据类型 (简称 GADT) 是 【变体的扩展】 

GADT 比常规变体更具表现力，这可以帮助您创建更精确地匹配您要编写的程序形状的类型。

这可以帮助您编写更安全、更简洁、更高效的代码。

*)


(* 
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

这里的语法需要一些解码。

每个标签   [右侧的冒号]  告诉您这是一个 GADT。

在冒号的右侧，您会看到 看起来  像普通的  【单参数函数类型】，您几乎可以这样想；

具体来说，作为 该特定标记的 【类型签名】，被视为类型构造函数。

【箭头 ->】 的 

左侧                表示     构造函数的参数类型，

右侧                确定     构造值的类型。







在 GADT 中每个标签的定义中，


          【箭头 ->】 右侧  是整个 GADT 类型的实例，每种情况下类型参数都有独立的选择。


重要的是，类型参数可以取决于    标签    和      参数的类型。


Eq 是一个类型参数完全由标签确定的示例：它始终对应于 bool expr 。 

If 是一个示例，其中类型参数取决于标记的参数，特别是 If 的类型参数是 then 和 else 子句的类型参数。

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
*)


(*
************************************************************************************************
************************************************************************************************
************************************************************************************************
************************************************************************************************
************************************************************************************************
************************************************************************************************




   
下跨线 _ 其实就是  类似  类型参数 'a 之类的， 只是用了 _ 后表示没有 去明确 类型参数 了   【泛型中的泛型 ??】


即表示:    【_ value 可能是  int value  也可能是  bool value】





************************************************************************************************
************************************************************************************************
************************************************************************************************
************************************************************************************************
************************************************************************************************
************************************************************************************************
*)

(* GADT 形式的  value 类型定义 *)
type _ value =
  | Int : int -> int value    (* Int : 入参类型 int  -> 返回类型 int value, 名曰 该 value 类型 构造子为 Int *)
  | Bool : bool -> bool value (* Bool : 入参类型 bool  -> 返回类型 bool value, 名曰 该 value 类型 构造子为 Bool *)


(* GADT 形式的  expr 类型定义 *)
type _ expr =
  | Value : 'a value -> 'a expr              (*************** Value : 入参类型  -> 返回类型 ***************)
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

这些类型安全规则    不仅适用于构造表达式，还适用于解构表达式。

这意味着我们可以编写一个更简单、更简洁的求值器，不需要任何类型安全检查。


但是 GADT 缺点： 


GADT 的缺点之一，即：  使用它们的代码需要额外的  【类型注释】

*)


(* 



  函数  eval_value (入参类型  a. a value)  -> (返参类型  a) 

        val eval_value : 'a value -> 'a = <fun>

  函数  eval_value 定义(去使用 GADT  类型  value 时)需要加 【类型注释】  type a. a value -> a
*)
let eval_value : type a. a value -> a = function
  | Int x -> x
  | Bool x -> x;;


(* 
   
    多态 eval 函数    【最终形态】

              val eval : 'a expr -> 'a = <fun> 

    同理，也要加       【类型注释】 
 
*)
let rec eval : type a. a expr -> a = function
  | Value v -> eval_value v
  | If (c, t, e) -> if eval c then eval t else eval e
  | Eq (x, y) -> eval x = eval y
  | Plus (x, y) -> eval x + eval y;;




(* 不加      【类型注释】     就会报错  *)
let eval_value = function
  | Int x -> x
  | Bool x -> x;;
(* 
Error: This pattern matches values of type bool value
       but a pattern was expected which matches values of type int value
       Type bool is not compatible with type int   
*)

(* 

****************************************************************************************************************************************

OCaml 默认情况下不愿意在同一函数体内以不同的方式实例化  普通类型变量，而这正是这里所需要的。

即： 

      type a. a value -> a  中的 a.

我们可以通过添加【本地抽象类型】来解决这个问题。

****************************************************************************************************************************************

*)
let eval_value (type a) (v : a value) : a =
  match v with
  | Int x -> x
  | Bool x -> x;;

(* 
   但是在 eval 函数中 对 type a. a expr -> a 添加 【本地抽象类型】 报错
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

这是一条非常无用的错误消息，

但基本问题是 eval 是递归的，

并且 GADT 的推理不能很好地 与 递归调用配合使用。


更具体地说：

问题是 类型检查器 试图将     【本地抽象类型】    a 合并到递归函数 eval 的类型中，

并将其合并到定义 eval 的外部范围中。其中 a 正在逃离其范围。
*)

(* 

****************************************************************************************************************************************
  解决 
  
  我们可以通过显式地将 eval 标记为多态来解决这个问题，OCaml 有一个方便的类型注释。

****************************************************************************************************************************************  
*)


(* 

通过将 eval 标记为多态， eval 的类型并不专用于 a ，因此 a 不会逃脱其范围。
   

因为 eval 本身就是多态递归的一个例子，也就是说 eval 需要在多种不同类型上调用自己。


例如， If 会出现这种情况，因为 If 本身必须是 bool 类型，但 then 和 else 子句的类型可以是 int 类型。
这意味着在评估 If 时，我们将以与调用时不同的类型分派 eval 。



----------------------------------------------------------------------------------
因此， eval 需要将自己视为多态的。
这种多态性基本上不可能自动推断 (就是说这种 多态 自己时推断不出来的)，这是我们需要显式注释 eval 的多态性的第二个原因。
----------------------------------------------------------------------------------

*)
(* val eval : 'a expr -> 'a = <fun> *)
let rec eval : 'a. 'a expr -> 'a =

  fun (type a) (x : a expr) ->     (* 注意， 将  【本地抽象类型】 写到这里了， 就是将  签名上的  【本地抽象类型】   改写到  fun 这里了 *)

   match x with
   | Value v -> eval_value v
   | If (c, t, e) -> if eval c then eval t else eval e
   | Eq (x, y) -> eval x = eval y
   | Plus (x, y) -> eval x + eval y;;

(* 

同这个：【这个才是   最终形态】

let rec eval : type a. a expr -> a = function
  | Value v -> eval_value v
  | If (c, t, e) -> if eval c then eval t else eval e
  | Eq (x, y) -> eval x = eval y
  | Plus (x, y) -> eval x + eval y;;   

*)


(* 
-------------------------------------------------------------------------------------------------
然而：
   
上面的语法有点冗长，因此 OCaml 有语法糖来结合 【多态性注释】 和 【本地抽象类型】  的创建：

最终写成：【最终形态】
-------------------------------------------------------------------------------------------------
*)






(* 
######################################################################################################################################################
什么时候用  GADT ？
######################################################################################################################################################
*)


(* 
************************************************************************************************************************************************
【一】 多样化 返回类型
************************************************************************************************************************************************
*)


(* 

如： 对于 List.find;; 函数

- : 'a list -> f:('a -> bool) -> 'a option = <fun> 

只能使用   数据如何流经代码相对应的类型之间的简单依赖关系 

即只能做到  'a  泛型，去使用  List.find   如：

*)

List.find ;;

List.find ~f:(fun x -> x > 3) [1;3;5;2];;

List.find ~f:(Char.is_uppercase) ['a';'B';'C'];;



(* 
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
   
假设我们想要创建一个 find 的版本，它可以在如何处理未找到项目的情况方面进行配置。您可能需要三种不同的行为：

Throw an exception. 抛出异常。
Return None. 返回 None 。
Return a default value. 返回一个默认值。

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
*)




(* 
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
不使用 GADT 的实现：
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
*)
module If_not_found = struct
  type 'a t =
    | Raise
    | Return_none
    | Default_to of 'a
end
(* 
flexible_find ，它将 If_not_found.t 作为参数并相应地改变其行为   

函数三个入参：

list

f

If_not_found.t

类型为：

val flexible_find : 'a list -> f:('a -> bool) -> 'a If_not_found.t -> 'a option = <fun>    [总是 返回一个 option]
*)
let rec flexible_find list ~f (if_not_found : _ If_not_found.t) =

  match list with
  (* 处理 hd *)
  | hd :: tl ->
    if f hd then Some hd else flexible_find ~f tl if_not_found
  | [] ->
    (match if_not_found with
    | Raise -> failwith "Element not found"
    | Return_none -> None
    | Default_to x -> Some x);;


(* - : int option = None *)
flexible_find ~f:(fun x -> x > 10) [1;2;5] Return_none;;

(* - : int option = Some 10 *)
flexible_find ~f:(fun x -> x > 10) [1;2;5] (Default_to 10);;

(* Exception: (Failure "Element not found"). *)
flexible_find ~f:(fun x -> x > 10) [1;2;5] Raise;;

(* - : int option = Some 20 *)
flexible_find ~f:(fun x -> x > 10) [1;2;20] Raise;;

(* 

【总结】

以上实现，基本上符合我们的要求，但问题是 flexible_find 总是返回一个 option ，即使它传递了 Raise 或 Default_to ，而 None 的情况永远不会被使用  [啥意思啊 ????]







为了消除 Raise 和 Default_to 情况下    不必要的 option ，我们将把 If_not_found.t 变成GADT。



特别是，我们将其创建为具有  两个类型参数  的 GADT：   一个用于 [列表元素的类型] ，   另一个用于  [函数的返回类型]。





----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
GADT 的实现：
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

*)


module If_not_found = struct


  type (_, _) t =

    (* Raise 是 入参为 ('a, 'a) 无返参的 类型  t *)
    | Raise : ('a, 'a) t

    (* Return_none 是 入参为 ('a, 'a option) 无返参的 类型  t *)
    (*  只有  Return_none 的 t 的 类型参数中 存在 option *)
    | Return_none : ('a, 'a option) t

    (* Default_to 是 入参为 'a 返参为 ('a, 'a) 的 类型  t *)
    | Default_to : 'a -> ('a, 'a) t
end



(* 对应的  flexible_find 函数为： *)

(* 

val flexible_find : f:('a -> bool) -> 'a list -> ('a, 'b) If_not_found.t -> 'b = <fun> 




'a 'b. f.('a -> bool) -> 'a list -> ('a, 'b) If_not_found.t -> 'b
 
*)

let rec flexible_find


  (* 
    val flexible_find : f:('a -> bool) -> 'a list -> ('a, 'b) If_not_found.t -> 'b = <fun>    
    'a 'b. f.('a -> bool) -> 'a list -> ('a, 'b) If_not_found.t -> 'b 
  *)
 : type a b. f:(a -> bool) -> a list -> (a, b) If_not_found.t -> b =
 fun ~f list if_not_found ->


  (* 先检查  list *)
  match list with


  (* 如果是 []，则查看 入参的意愿返回类型 *)
  | [] ->
    (match if_not_found with

    (* 如果意愿 返回 Raise : (a, b) t  类型 *)
    | Raise -> failwith "No matching item found"
    | Return_none -> None
    | Default_to x -> x)
  | hd :: tl ->
    if f hd
    then (
      match if_not_found with
      | Raise -> hd
      | Return_none -> Some hd
      | Default_to _ -> hd)
    else flexible_find ~f tl if_not_found;;


(* 

正如您从 flexible_find 的签名中看到的，返回值现在取决于 If_not_found.t 的类型，

这意味着它可以取决于正在使用的 If_not_found.t 的特定变体。

因此， flexible_find 仅在需要时返回 option。

*)

flexible_find ~f:(fun x -> x > 10) [1;2;5] Return_none;;

flexible_find ~f:(fun x -> x > 10) [1;2;5] (Default_to 10);;

flexible_find ~f:(fun x -> x > 10) [1;2;5] Raise;;

flexible_find ~f:(fun x -> x > 10) [1;2;20] Raise;;







(* 
************************************************************************************************************************************************
【二】 捕捉 未知类型
************************************************************************************************************************************************
*)


(* 
   val tuple : 'a -> 'b -> 'a * 'b = <fun> 
   
   类型变量 'a 和 'b 表示这里有两个未知类型，并且这些类型变量是 [通用量化] 的。
   
   也就是说， tuple 的类型是：对于所有类型 a 和 b ， a -> b -> a * b
*)
let tuple x y = (x,y);;

(* 
----------------------------------------------------------------------------------------------------------------------------------

【限制类型  的语法】

可以将 tuple 的类型限制为我们想要的任何 'a 和 'b 

----------------------------------------------------------------------------------------------------------------------------------
*)
(tuple : int -> float -> int * float);;

let  tupleFn = (tuple : string -> string * string -> string * (string * string));;

tupleFn 1 2;;   (* This expression has type int but an expression was expected of type string *)




(* 
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

然而，有时我们需要存在量化的类型变量，这意味着该类型不是与所有类型兼容，而是表示特定但未知的类型


[GADT 提供了一种对此类类型变量进行编码的自然方式]:


----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
*)


(* 

该类型将某种 任意类型的值 value  ； 以及用于 将该类型的值转换为字符串的函数 to_string  打包在一起


类型 stringable 的 构造子 为  Stringable, 其中  Stringable 由 { value: 'a; to_string: 'a -> string } 组成


查看最上面的  type  value 就明白了  -> 左右的含义了

*)
type stringable = Stringable : { value: 'a; to_string: 'a -> string } -> stringable



let print_stringable (Stringable s) =
  print_endline (s.to_string s.value);;


(* 
语法讲解： 

let stringables = stringable list = let 函数s 入参 value  to_string =  Stringable { to_string; value } in [...]




val stringables : stringable list =
    [Stringable {value = <poly>; to_string = <fun>};
     Stringable {value = <poly>; to_string = <fun>};
     Stringable {value = <poly>; to_string = <fun>}]

*)
let stringables =
  (let s value to_string = Stringable { to_string; value } in
    [ s 100 Int.to_string
    ; s 12.3 Float.to_string
    (* ; s "foo" Fn.id *)
    ]);;
  
  
  
(* 
   逐个遍历
*)
List.iter print_stringable stringables;;
  
(* 
让这一切起作用的是底层对象的类型存在地绑定在类型 stringable 内。

因此，基础值的类型无法逃脱 stringable 的范围，并且任何尝试返回此类值的函数都不会进行类型检查。  

(stringable 是一个整体，不能单独使用  stringable.value 等，因为无法推断。)

*)
let get_value (Stringable s) = s.value;;

(* 
   
Error: This expression has type $Stringable_'a
       but an expression was expected of type 'a
       The type constructor $Stringable_'a would escape its scope

type $Stringable_'a 我们可以理解为下面三部分：


1、 $ 将变量标记为 存在变量

2、 Stringable 是该变量来自的 GADT 标记的名称

3、 'a 是该标记 [内部] 类型变量的名称

*)



(* 
************************************************************************************************************************************************
【三】 抽象 计算机器
************************************************************************************************************************************************
*)


(* 
   
OCaml 中的一个常见习惯是使用组件组合函数或组合器的集合将小型组件组合成更大的计算机器

*)
  
(* 

自定义管道


好处:

1、 跟踪管道执行时长

2、 控制管道执行 (如： 暂停)

3、 自定义 错误处理  (如: 构建一个管道来跟踪失败的位置，并提供重新启动它的可能性)


*)

module type Pipeline = sig

  (* 
  类型 ('a,'b) t 表示一个管道，它消耗 'a 类型的值并发出 'b 类型的值。
  运算符 @> 允许您通过提供一个预先添加到现有管道的函数来向管道添加步骤，
  而 empty 则为您提供一个空管道，可用于为管道提供种子 
  *)
  type ('input,'output) t

  val ( @> ) : ('a -> 'b) -> ('b,'c) t -> ('a,'c) t
  val empty : ('a,'a) t
end


(* 
使用  函子   

module Example_pipeline :
  functor (Pipeline : Pipeline) ->
    sig val sum_file_sizes : (unit, int) Pipeline.t end
*)
module Example_pipeline (Pipeline : Pipeline) = struct
  open Pipeline
  let sum_file_sizes =
    (fun () -> Sys_unix.ls_dir ".")
    @> List.filter ~f:Sys_unix.is_file_exn
    @> List.map ~f:(fun file_name -> (Core_unix.lstat file_name).st_size)
    @> List.sum (module Int) ~f:Int64.to_int_exn
    @> empty
end;;


(* 

如果我们想要的只是一个能够简单执行的管道，我们可以将管道本身定义为一个简单的函数，将 @> 运算符定义为函数组合。然后执行管道只是函数应用程序

*)

module Basic_pipeline : sig
  include Pipeline
  val exec : ('a,'b) t -> 'a -> 'b
end= struct
 type ('input, 'output) t = 'input -> 'output

 let empty = Fn.id

 let ( @> ) f t input =
   t (f input)

 let exec t input = t input
end


(* 

上述的写法不太好。


----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------


使用 GADT 实现 管道


----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------



使用 GADT 来抽象地表示我们想要的管道，然后在该表示之上构建我们想要的功能，而不是具体构建用于执行管道的机器

*)
type (_, _) pipeline =      (* 标签 pipeline 代表管道的两个构建块： Step 对应于 @> 运算符;    Empty 对应于 empty 管道 *)

  | Step : ('a -> 'b) * ('b, 'c) pipeline -> ('a, 'c) pipeline
  | Empty : ('a, 'a) pipeline



(* 
   
函数 @>


val ( @> ) : ('a -> 'b) -> ('b, 'c) pipeline -> ('a, 'c) pipeline = <fun>
*)
let ( @> ) f pipeline = Step (f, pipeline);;


(* 
   
val empty : ('a, 'a) pipeline = Empty

*)
let empty = Empty;;


(* 

val exec : ('a, 'b) pipeline -> 'a -> 'b = <fun>

*)
let rec exec : type a b. (a, b) pipeline -> a -> b =
  fun pipeline input ->
   match pipeline with
   | Empty -> input
   | Step (f, tail) -> exec tail (f input);;
 


(* 

执行管道并生成一个配置文件，显示管道每个步骤花费的时间   

val exec_with_profile : ('a, 'b) pipeline -> 'a -> 'b * Time_ns.Span.t list = <fun>

*)
let exec_with_profile pipeline input =
  let rec loop
      : type a b.
        (a, b) pipeline -> a -> Time_ns.Span.t list -> b * Time_ns.Span.t list
    =
   fun pipeline input rev_profile ->
    match pipeline with
    | Empty -> input, rev_profile
    | Step (f, tail) ->
      let start = Time_ns.now () in
      let output = f input in
      let elapsed = Time_ns.diff (Time_ns.now ()) start in
      loop tail output (elapsed :: rev_profile)
  in
  let output, rev_profile = loop pipeline input [] in
  output, List.rev rev_profile;;







(* 
************************************************************************************************************************************************
【四】 缩小  可能性
************************************************************************************************************************************************


缩小给定数据类型在不同情况下的可能状态集

*)


(* 
   
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

非 GADT

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------


我们可能会按如下方式对单个登录请求的状态进行建模

*)

(* 
   
User_name.t       代表文本名称 
User_id.t         代表与用户关联的整数标识符
Permissions.t     可以让您确定哪些 User_id.t 有权登录

*)
type logon_request =
  { user_name : User_name.t
  ; user_id : User_id.t option
  ; permissions : Permissions.t option
  }


(* 

测试 登录
val authorized : logon_request -> (bool, string) result = <fun>   
*)
let authorized request =
  match request.user_id, request.permissions with
  | None, _ | _, None ->
    Error "Can't check authorization: data incomplete"
  | Some user_id, Some permissions ->
    Ok (Permissions.check permissions user_id);;  


(* 

上面的代码对于像这样的简单情况来说效果很好。但在真实的系统中，您的代码可能会以多种方式变得更加复杂，例如，

    1、 更多要管理的字段，包括更多可选字段
    2、 更多依赖于这些可选字段的操作
    3、 并行处理多个请求，每个请求可能处于不同的完成状态 

*)


(*   
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

 GADT     [未实现]

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
*)



(* 
*****************************************************************    
完成敏感   的 [选项] 类型     complete-sensitive option type
***************************************************************** 
*)
type incomplete = Incomplete
type complete = Complete
(* 

【我们使用 Absent 和 Present 而不是 Some 或 None 来使 option 和 coption 一起使用时代码不那么混乱】



这里没有明确使用 complete 。
相反，我们所做的是确保只有 incomplete coption 可以是 Absent 。
因此， coption 是 complete （因此不是 incomplete ）只能是 Present
*)
type (_, _) coption =    
  | Absent : (_, incomplete) coption   (* Absent  => (_, incomplete) coption *)
  | Present : 'a -> ('a, _) coption    (* Present('a)  => ('a, _) coption *)



(* 

示例：  从 coption 中获取值，如果找到 Absent 则返回默认值


val get : default:'a -> ('a, incomplete) coption -> 'a = <fun>
*)
let get ~default o =
  match o with
  | Present x -> x
  | Absent -> default;;

  (* 此处推断出 incomplete 类型。如果我们将 coption 注释为 complete ，则代码将不再编译 *)

let get ~default (o : (_,complete) coption) =
  match o with
  | Absent -> default  (* 由于 get 函数入参 o 限定了是   (_,complete) coption , 则 Absent 不符合， 因为它是 (_, incomplete) coption *)
  | Present x -> x;;
  
  (* 
  Error: This pattern matches values of type ('a, incomplete) coption
       but a pattern was expected which matches values of type
         ('a, complete) coption
       Type incomplete is not compatible with type complete   
  *)
  
  (*  下列两个函数是等价的  *)

let get (o : (_,complete) coption) =
  match o with
  | Present x -> x;;

let get (Present x : (_,complete) coption) = x;;    (* 构造子 Present x 实例化后的类型是(_,complete) coption *)
  
  


(* 
*****************************************************************    
类型区别 和 抽象  
***************************************************************** 
*)

(* 本质意义上  incomplete 和 complete 是不同类型的哦 *)
type incomplete = Z
type complete = Z

(* 
   
如果我们用下列形式定义，则 


容易忽视的问题是，我们通过接口公开这些类型的方式可能会导致 OCaml 无法跟踪相关类型的独特性
*)

type ('a, _) coption =
  | Absent : (_, incomplete) coption
  | Present : 'a -> ('a, _) coption

let assume_complete (coption : (_,complete) coption) =
  match coption with
  | Present x -> x;;


(* 

所以，我们完全隐藏了 complete 和 incomplete 的定义， 如：

将其定义在 模块 M 中

*)

module M : sig
  type incomplete
  type complete
end = struct
  type incomplete = Z
  type complete = Z
end
include M

type ('a, _) coption =
  | Absent : (_, incomplete) coption
  | Present : 'a -> ('a, _) coption



(* 

紧接着， 我们编写的 assume_complete 函数不再是详尽的


val assume_complete : ('a, complete) coption -> 'a = <fun>
*)
let assume_complete (coption : (_,complete) coption) =
  match coption with
  | Present x -> x;;
(* 

Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
Absent


因为通过保留类型抽象，我们  完全隐藏了底层类型，使  【类型系统】 没有  证据表明类型是不同的
*)


(* 

让我们看看如果我们公开这些类型的实现会发生什么

*)
module M : sig
  type incomplete = Z   (* 在 [签名 定义] 这，直接 赋上 Z， 即表示  公开 *)
  type complete = Z     (* 在 [签名 定义] 这，直接 赋上 Z， 即表示  公开 *)
end = struct
  type incomplete = Z
  type complete = Z
end
include M

type ('a, _) coption =
  | Absent : (_, incomplete) coption
  | Present : 'a -> ('a, _) coption

let assume_complete (coption : (_,complete) coption) =
  match coption with
  | Present x -> x;;
(* 

Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
Absent


结果仍然不详尽 !!!!! 

【结论】：当创建类型作为 GADT 类型参数的抽象标记时，应该选择使这些类型的独特性变得清晰的定义，并且应该在 mli 中公开这些定义
*)





(* 
************************************************************************************************************************************************
************************************************************************************************************************************************

GADT 的局限性

************************************************************************************************************************************************
************************************************************************************************************************************************
*)


(* 
*****************************************************************    
【1】   GADT 不能很好地与 or 模式配合使用
***************************************************************** 
*)

open Core
module Source_kind = struct
  type _ t =
    | Filename : string t
    | Host_and_port : Host_and_port.t t
    | Raw_data : string t
end

let source_to_sexp (type a) (kind : a Source_kind.t) (source : a) =
  match kind with
  | Filename -> String.sexp_of_t source
  | Host_and_port -> Host_and_port.sexp_of_t source
  | Raw_data -> String.sexp_of_t source;;

  (* 改写成 OR 模式 *)

  let source_to_sexp (type a) (kind : a Source_kind.t) (source : a) =
    match kind with
    | Filename | Raw_data -> String.sexp_of_t source
    | Host_and_port -> Host_and_port.sexp_of_t source;;
(* 

Error: This expression has type a but an expression was expected of type
         string

         不支持 OR 模式

*)
  
  

(* 
*****************************************************************    
【2】   GADT 不适用 PPX 的 派生序列化器   [@@deriving sexp]
***************************************************************** 
*)
type _ number_kind =
  | Int : int number_kind
  | Float : float number_kind
[@@deriving sexp];;
(* 
Error: This expression has type int number_kind
       but an expression was expected of type a__007_ number_kind
       Type int is not compatible with type a__007_   


number_kind_of_sexp 的类型到底应该是什么？

解析 "Int" 时，返回的类型必须是 int number_kind ，
解析 "Float" 时，返回的类型必须是 float number_kind 。

参数值和返回值类型之间的这种依赖关系在 OCaml 的类型系统中无法表达。       
*)

(* 

但，仅创建序列化器的 [@@deriving sexp_of] 工作得很好


type _ number_kind = Int : int number_kind | Float : float number_kind

val sexp_of_number_kind :
  ('a__001_ -> Sexp.t) -> 'a__001_ number_kind -> Sexp.t = <fun>
*)
type _ number_kind =
 | Int : int number_kind
 | Float : float number_kind
[@@deriving sexp_of];;


(* - : Sexp.t = Int *)
sexp_of_number_kind Int.sexp_of_t Int;;
