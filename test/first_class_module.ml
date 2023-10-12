(* 
######################################################################################################################################################

第一类 模块：

######################################################################################################################################################


OCaml 视为分为两部分：涉及值和类型的核心语言，以及涉及模块和模块签名的模块语言。



这些子语言是分层的：

  因为 模块 可以包含 类型 和 值，
  但 普通值 不能包含 模块 或 模块类型。

这意味着不能执行诸如： 定义值 为 模块的变量 或将 模块作为参数的函数 之类的操作。





【解决】：   第一类模块
*)


(* 
   
第一类模块是通过打包具有其满足的签名的模块来创建的。这是使用 module 关键字完成的。

*)

module type X_int = sig val x : int end;;

(* 函子 *)
module Three : X_int = struct let x = 3 end;;

Three.x;;

(* 
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
*************************************************   
将 函子 转成 第一类模块
*************************************************


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


转换语法：


let  第一类模块名 = (module 要被转的一般模块 :  一般模块的类型)


let first-class-moduleName = (module moduleName : moduleType)

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
*)
let three = (module Three : X_int);;    (* val three : (module X_int) = <module> *)



(* 
*************************************************   
推断 和 匿名模块
*************************************************
*)
module Four = struct let x = 4 end;;   (* 通过类型推断，其类型为 module X_int *)  (* module Four : sig val x : int end *)

(* val numbers : (module X_int) list = [<module>; <module>] *)
let numbers = [ three; (module Four) ];;   (* 类型推断 Four 为  第一类模块 *)
(* 还可以写成 匿名模块 *)
let numbers = [three; (module struct let x = 4 end)];;



(* 
*************************************************   
拆开  第一类 模块
*************************************************



为了访问一流模块的内容，您需要将其解包到普通模块中。这可以使用 val 关键字来完成：


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


拆开语法：

  


  module 拆解出来的一般模块 = (val 第一类模块名  : 一般模块的类型)

  module moduleName = (val first-class-moduleName : moduleType)
    


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

*)

(* module New_three : X_int *)
module New_three = (val three : X_int);;    (* 【注意， 看这个啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊  !!!!!!!!!!!!!!!!!!!!!!1】 *)

New_three.x;;


(* 

【结论】：

    想要在 函数中使用  module 参数：

        则需要先将 module 转换成  第一类模块；

        并在要是用的地方 解开 第一类模块为 普通模块

*)



(* 
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
*************************************************   
用于 操作 第一类 模块的 函数
*************************************************
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
*)

(* val to_int : (module X_int) -> int = <fun> *)
let to_int m =
  let module M = (val m : X_int) in
  M.x;;


(* val plus : (module X_int) -> (module X_int) -> (module X_int) = <fun> *)
let plus m1 m2 =(module struct let x = to_int m1 + to_int m2 end : X_int);;


(* 使用模式匹配 *)
let to_int (module M : X_int) = M.x;;  (* 比上面的  to_int 定义 简洁 *)  




let six = plus three three;;
to_int (List.fold_left  plus six [three;three]);;


(* 
*************************************************   
更丰富的例子
*************************************************
*)

(* module  type *)
module type Bumpable = sig
  type t
  val bump : t -> t
end;;


module Int_bumper = struct
  type t = int
  let bump n = n + 1
end;;

module Float_bumper = struct
  type t = float
  let bump n = n +. 1.
end;;

let int_bumper = (module Int_bumper : Bumpable);;

(* 注意：  第一类模块 不可以直接被使用， 因为它是 抽象的 *)
let (module Bumper) = int_bumper in Bumper.bump 3;;
(* 
Error:  This expression has type Bumper.t but an expression was expected of type 'a
        The type constructor Bumper.t would escape its scope   
*)


(* 为了使 int_bumper 可用，我们需要公开类型 Bumpable.t 实际上等于 int 。下面我们将为 int_bumper 执行此操作，并为 float_bumper 提供相应的定义。 *)

(* 添加   【共享限制】 *)

let int_bumper = (module Int_bumper : Bumpable with type t = int);;

let float_bumper = (module Float_bumper : Bumpable with type t = float);;



let (module Bumper) = int_bumper in Bumper.bump 3;;

let (module Bumper) = float_bumper in Bumper.bump 3.5;;


(* 
*************************************************   
还可以多态地使用这些一流的模块
*************************************************

以下函数采用两个参数： Bumpable 模块 和与  模块的 t 类型相同类型的元素列表：   (即   下列的 a 【本地抽象类型】)
*)

(* val bump_list : (module Bumpable with type t = 'a) -> 'a list -> 'a list = <fun> *)
let bump_list  (type a)  (module Bumper : Bumpable with type t = a) (l: a list)  =  List.map Bumper.bump l;;

bump_list int_bumper [1;2;3];;

bump_list float_bumper [1.5;2.5;3.5];;

(* 
在此示例中， a 是 【本地抽象类型】。

对于任何函数，您都可以声明 (type a) 形式的 伪参数，它引入了名为 a 的新类型。

该类型的作用： 类似于函数上下文中的抽象类型。

在上面的示例中，本地抽象类型用作共享约束的一部分，【该共享约束将类型 B.t 与传入的列表元素的类型联系起来】。  


(可知  【本地抽象类型】 就是将 某些事务关联起来的)
*)


(* 

【本地抽象类型】 的关键属性之一是，它们在定义的函数中作为抽象类型进行处理，但从外部来看是多态的   

*)
let wrap_in_list (type a) (x:a) = [x];;

wrap_in_list 18;;

wrap_in_list true;;

wrap_in_list "Gavin";;

(* 

但是， 如果我们尝试使用 【本地抽象类型】  a ，就好像它相当于某种具体类型，例如 int ，那么编译器会抱怨。

*)
let double_int (type a) (x:a) = x + x;;  (* Error: This expression has type a but an expression was expected of type int *)

(* 
   
【本地抽象类型】 的一个常见用途是    【创建 可用于构造模块 的 新类型】 。

这是创建新的  第一类模块的示例: 

*)

module type Comparable = sig
  type t
  val compare : t -> t -> int
end;;

(* val create_comparable :  ('a -> 'a -> int) -> (module Comparable with type t = 'a) = <fun> *)
let create_comparable (type a) compare =   (* 使用 【本地抽象类型】*)
  (module struct
    type t = a
    let compare = compare
  end : Comparable with type t = a);;  (* 使用 【共享限制】 *)


create_comparable Int.compare;;     (* - : (module Comparable with type t = int) = <module> *)

create_comparable Float.compare;;   (* - : (module Comparable with type t = float) = <module> *)



(* 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   

示例： 查询处理框架

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*)