(* 

    ##################################
    ##############      ##############
    ############## 函子 ##############
    ##############      ##############
    ##################################
    ############          ############
    ############  函数器  ############
    ############          ############
    ##################################
    ############          ############
    ############  仿函数  ############
    ############          ############
    ##################################






######################################################################################################################################################


    【函数器】本质上是根据 其他模块 编写 模块 的一种方式

    【仿函数】是一个由【另一个模块】参数化的模块，
    就像【函数】是一个由【其他值】（参数）参数化的值一样


######################################################################################################################################################



---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

    【module 名称 (参数名称 : 签名表达式) = 模块化表达式】


    以下糖衣语法:

    【module 名称 = functor (参数名称 : 签名表达式) -> 模块化表达式  】


---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------



######################################################################################################################################################
*)


(* 
######################################################################################################################################################
【不】具备返回值的写法 
######################################################################################################################################################
*)

(* 
    签名定义  (也是 命名模块类型 (模块类型定义))
    (查看 module_test.ml 文件对比)

    module type ELEMENT = sig type t val compare : t -> t -> int end


    下面这个是 module 的类型签名 定义
*)
module type ELEMENT = sig
  type t
  val compare: t -> t -> int
end

(* 
****************************************************************************************************************************************

    functor

    语法： 
    
    (* X 是将作为参数传递的模块， X_type 是它的签名 *)

    ********************************************************************
    module F (X : X_type) = struct   
      ...
    end
    ********************************************************************

    或者

    ********************************************************************
    module F (X : X_type) : Y_type = struct
      ...
    end
    ********************************************************************

    或者 通过在 .mli 文件中指定：

    ********************************************************************
    module F (X : X_type) : Y_type
    ********************************************************************

    如：

    使用  functor 关键字时的 写法

    module MakeSet = functor (Element : ELEMENT) ->
      sig
        type elt = Element.t
        type t = elt list
        val empty : 'a list
        val mem : Element.t -> Element.t list -> bool
        val add : Element.t -> Element.t list -> Element.t list
        val elements : 'a -> 'a
      end

****************************************************************************************************************************************


下面这个是   函子  MakeSet 的定义：

*)
module MakeSet (Element : ELEMENT) =
  struct

    type elt = Element.t  (* 使用 ELEMENT 的 t 作为 elt *)
    type t = elt list  (* 自己的 t 则是 elt list 也就是 ELEMENT.t list *)

    let empty = []  (* empty 函数 *)

    let mem x set = List.exists (fun y -> Element.compare x y = 0) set

    let rec add elt = function  (* 往 list 中添加新元素的 add 函数 *)
                            | [] -> [elt]
                            (* 从 list 中的 首元素 开始 比较 *)
                            | (x :: rest as s) ->

                                match Element.compare elt x with
                                (* 如果 等于首元素， 则不做 add 操作 *)
                                | 0 -> s
                                (* 如果 不等于 首元素 且 < 0 则加到 list 头部 *)
                                | r when r < 0 -> elt :: s
                                (* 否则，对比 list 下一个 元素 *)
                                | _ -> x :: (add elt rest)

    let rec elements s = s
  end;;



(* 
****************************************************************************************************************************************

    使用函子实例化一个  String 类型的 StringSet module：

    module StringSet :
      sig
        type elt = String.t
        type t = elt list
        val empty : 'a list
        val mem : String.t -> String.t list -> bool
        val add : String.t -> String.t list -> String.t list
        val elements : 'a -> 'a
      end 

****************************************************************************************************************************************      
*)

module StringSet = MakeSet(struct
    type t = string
    let compare = compare
  end);;



(* 
######################################################################################################################################################
具备返回值的写法
######################################################################################################################################################
*)


(* 
    module 名称 (参数名称 : 输入签名表达式)  : 签名表达式返回 = 模块表达式   

*)
module MakeSet (Element : ELEMENT) :

  (* 签名表达式返回 *)
  sig
    type elt = Element.t
    type t (* 抽象数据类型 *)
    val mem : elt -> t -> bool
    val add : elt -> t -> t
    val elements : t -> elt list
  end


  =


  (* 模块化: 模块表达式  *)
  struct
    type elt = Element.t
    type t = elt list

    let empty = []

    let mem x set = List.exists (fun y -> Element.compare x y = 0) set

    let rec add elt = function
    | [] -> [elt]
    | (x :: rest as s) ->
        match Element.compare elt x with
        | 0 -> s
        | r when r < 0 -> elt :: s
        | _ -> x :: (add elt rest)

    let rec elements s = s
  end;;  
  



(* 
****************************************************************************************************************************************

    使用函子实例化一个  Int  类型的 IntSet module 并返回 (可以用变量接收该返回 module 的值)： 

    module IntSet :
      sig
        type elt = int
        type t (* 抽象数据类型 *)
        val empty : t
        val mem : elt -> t -> bool
        val add : elt -> t -> t
        val elements : t -> elt list
      end

****************************************************************************************************************************************      
*)
module IntSet = MakeSet(struct
    type t = int
    let compare i j = i - j
  end);;


(* 
    val s1 : IntSet.t = <abstr> (* 抽象数据类型 *)
    val s2 : IntSet.t = <abstr>   
*)
open IntSet;;
let s1 = add 1 (add 2 empty) and s2 = add 3 (add 4 empty);;


(* 

****************************************************************************************************************************************
    
    使用函子实例化一个  String  类型的 StringSet module 并返回 (可以用变量接收该返回 module 的值)：

    module StringSet :
      sig
        type elt = String.t
        type t = MakeSet(String).t (* 有隐藏的实现吗？ *)
        val empty : t
        val mem : elt -> t -> bool
        val add : elt -> t -> t
        val elements : t -> elt list
      end

****************************************************************************************************************************************      
*)
module StringSet = MakeSet(struct
    type t = string
    let compare i j = 0
  end);;

(* 
    val s1 : StringSet.t = <abstr> (* 这是一个抽象的数据类型 *)
    val s2 : StringSet.t = <abstr>
*)
open StringSet;;
let s1 = add "a" (add "b" empty) and s2 = add "c" (add "d" empty);;




(* 
######################################################################################################################################################
显式 指定某个 sig 中的字段值并生成新字段        【共享约束】  
######################################################################################################################################################

module type 新类型 = 旧类型 with type elt = 被指定的类型;;   如：   

module type E2 = E1 with type elt = int;;


*)

(* 定义新的 module 类型 E1 *)
module type E1 =
    sig
      type elt
      type t
      val empty : t
      val mem : elt -> t -> bool
      val add : elt -> t -> t
      val elements : t -> elt list
    end;;

(* 
********************************************************************   
with type 指定 E1 的 elt 字段并定义 E2
********************************************************************
*)

(* 
********************************************************************
  使用 被用 int 指定泛型后的 E1 类型 声明为新 module 类型： E2
********************************************************************

  E2 module 的类型为：

    module type E2 =
      sig
        type elt = int
        type t
        val empty : t
        val mem : elt -> t -> bool
        val add : elt -> t -> t
        val elements : t -> elt list
      end
*)
module type E2 = E1 with type elt = int;;






(* 
********************************************************************
示例    使用 Set 库的 Make() 函子 实例化一个 int 类型的 Set module
********************************************************************
*)

(* 
module 类型：

module Int_set :
  sig
    type elt = int
    type t
    val empty : t
    val is_empty : t -> bool
    val mem : elt -> t -> bool
    val add : elt -> t -> t
    val singleton : elt -> t
    val remove : elt -> t -> t
    val union : t -> t -> t
    val inter : t -> t -> t
    val disjoint : t -> t -> bool
    val diff : t -> t -> t
    val compare : t -> t -> elt
    val equal : t -> t -> bool
    val subset : t -> t -> bool
    val iter : (elt -> unit) -> t -> unit
    val map : (elt -> elt) -> t -> t
    val fold : (elt -> 'a -> 'a) -> t -> 'a -> 'a
    val for_all : (elt -> bool) -> t -> bool
    val exists : (elt -> bool) -> t -> bool
    val filter : (elt -> bool) -> t -> t
    val filter_map : (elt -> elt option) -> t -> t
    val partition : (elt -> bool) -> t -> t * t
    val cardinal : t -> elt
    val elements : t -> elt list
    val min_elt : t -> elt
    val min_elt_opt : t -> elt option
    val max_elt : t -> elt
    val max_elt_opt : t -> elt option
    val choose : t -> elt
    val choose_opt : t -> elt option
    val split : elt -> t -> t * bool * t
    val find : elt -> t -> elt
    val find_opt : elt -> t -> elt option
    val find_first : (elt -> bool) -> t -> elt
    val find_first_opt : (elt -> bool) -> t -> elt option
    val find_last : (elt -> bool) -> t -> elt
    val find_last_opt : (elt -> bool) -> t -> elt option
    val of_list : elt list -> t
    val to_seq_from : elt -> t -> elt Seq.t
    val to_seq : t -> elt Seq.t
    val to_rev_seq : t -> elt Seq.t
    val add_seq : elt Seq.t -> t -> t
    val of_seq : elt Seq.t -> t
  end
*)
module Int_set =
  Set.Make (struct
              type t = int
              let compare = compare
            end);;




(* 
********************************************************************
示例    使用 Set 库的 Make() 函子 实例化一个 String 类型的 Set module
********************************************************************
*)

(* 
module String_set :
  sig
    type elt = string
    type t = Set.Make(String).t
    val empty : t
    val is_empty : t -> bool
    val mem : elt -> t -> bool
    val add : elt -> t -> t
    val singleton : elt -> t
    val remove : elt -> t -> t
    val union : t -> t -> t
    val inter : t -> t -> t
    val disjoint : t -> t -> bool
    val diff : t -> t -> t
    val compare : t -> t -> int
    val equal : t -> t -> bool
    val subset : t -> t -> bool
    val iter : (elt -> unit) -> t -> unit
    val map : (elt -> elt) -> t -> t
    val fold : (elt -> 'a -> 'a) -> t -> 'a -> 'a
    val for_all : (elt -> bool) -> t -> bool
    val exists : (elt -> bool) -> t -> bool
    val filter : (elt -> bool) -> t -> t
    val filter_map : (elt -> elt option) -> t -> t
    val partition : (elt -> bool) -> t -> t * t
    val cardinal : t -> int
    val elements : t -> elt list
    val min_elt : t -> elt
    val min_elt_opt : t -> elt option
    val max_elt : t -> elt
    val max_elt_opt : t -> elt option
    val choose : t -> elt
    val choose_opt : t -> elt option
    val split : elt -> t -> t * bool * t
    val find : elt -> t -> elt
    val find_opt : elt -> t -> elt option
    val find_first : (elt -> bool) -> t -> elt
    val find_first_opt : (elt -> bool) -> t -> elt option
    val find_last : (elt -> bool) -> t -> elt
    val find_last_opt : (elt -> bool) -> t -> elt option
    val of_list : elt list -> t
    val to_seq_from : elt -> t -> elt Seq.t
    val to_seq : t -> elt Seq.t
    val to_rev_seq : t -> elt Seq.t
    val add_seq : elt Seq.t -> t -> t
    val of_seq : elt Seq.t -> t
  end    
*)
module String_set =
  Set.Make (struct
              type t = String
              let compare = compare
            end);;
           




(* 
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################

函子的应用

######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
*)

(* 
*******************************************  
一个简单的例子
*******************************************
*)
(* 模块类型 *)
module type X_int = sig val x : int end;;

(* 定义 声明了 返回 module类型的函子 *)
(* module Increment : functor (M : X_int) -> X_int *)
module Increment1 (M : X_int) : X_int = struct
  let x = M.x + 1
end;;

(* 定义 无声明 返回 module类型的函子 *)
(* module Increment : functor (M : X_int) -> sig val x : int end *)
module Increment2 (M : X_int) = struct
  let x = M.x + 1
end;;


(* 适用函子 定义新 module *)
module Three = struct let x = 3 end;;

module Four1 = Increment1(Three);;
module Four2 = Increment2(Three);;

print_int (Four1.x - Three.x);;   (*  1 *)
print_int (Four2.x - Three.x);;   (*  1 *)



(* 
*******************************************  
一个复杂的例子
*******************************************
*)

module type Comparable = sig
  type t
  val compare : t -> t -> int
end;;


(* 
   
用于创建间隔模块的函子 


module Make_interval :
  functor (Endpoint : Comparable) ->
    sig
      type t = Interval of Endpoint.t * Endpoint.t | Empty
      val create : Endpoint.t -> Endpoint.t -> t
      val is_empty : t -> bool
      val contains : t -> Endpoint.t -> bool
      val intersect : t -> t -> t
    end
*)
module Make_interval(Endpoint : Comparable) = struct

  type t = | Interval of Endpoint.t * Endpoint.t
           | Empty

  (** [create low high] creates a new interval from [low] to
      [high].  If [low > high], then the interval is empty *)
  let create low high =
    if Endpoint.compare low high > 0 then Empty
    else Interval (low,high)

  (** Returns true iff the interval is empty *)
  let is_empty = function
    | Empty -> true
    | Interval _ -> false

  (** [contains t x] returns true iff [x] is contained in the
      interval [t] *)
  let contains t x =
    match t with
    | Empty -> false
    | Interval (l,h) ->
      Endpoint.compare x l >= 0 && Endpoint.compare x h <= 0

  (** [intersect t1 t2] returns the intersection of the two input
      intervals *)
  let intersect t1 t2 =  (* 求交集 *)
    let min x y = if Endpoint.compare x y <= 0 then x else y in
    let max x y = if Endpoint.compare x y >= 0 then x else y in
    match t1,t2 with
    | Empty, _ | _, Empty -> Empty
    | Interval (l1,h1), Interval (l2,h2) ->
      create (max l1 l2) (min h1 h2)
  
  (* let print = function
  | Empty -> print_endline "nothing"
  | Interval (l, h) -> Printf.printf "%a " l *)

end;;


(* 使用 *)
module Int_interval =
  Make_interval(struct
    type t = int
    let compare = Int.compare
end);;


module String_interval =
  Make_interval(struct
    type t = string
    let compare = String.compare
end);;


module Float_interval =
  Make_interval(struct
    type t = float
    let compare = Float.compare
end);;


module Int_interval = Make_interval(Int);;

module Float_interval = Make_interval(Float);;

module String_interval = Make_interval(String);;


let i1 = Int_interval.create 3 8;;

let i2 = Int_interval.create 4 10;;

Int_interval.intersect i1 i2;;  (* - : Int_interval.t = Int_interval.Interval (4, 8) *)


(* 得到倒序的  *)
module Rev_int_interval =
  Make_interval(struct
    type t = int
    let compare x y = Int.compare y x  (* 倒序实现 *)
end);;


let interval = Int_interval.create 4 3;;




let rev_interval = Rev_int_interval.create 4 3;;

(* 

Rev_int_interval.t 与 Int_interval.t 是不同的类型，尽管其物理表示相同   


Error: This expression has type Rev_int_interval.t
       but an expression was expected of type Int_interval.t
*)
Int_interval.contains rev_interval 3;;



(* 
*******************************************  
使函子变得抽象
*******************************************
*)

(* 

Make_interval 有问题。我们编写的代码取决于区间上限大于下限的不变量，但该不变量可能会被违反。

该不变量由 create 函数强制执行，但由于 Int_interval.t 不是抽象的，因此我们可以绕过 create 函数:

*)
Int_interval.is_empty (Int_interval.create 4 3);;   (* going through create *)

Int_interval.is_empty (Int_interval.Interval (4,3));;  (* by passing create, 【这 可以绕过 create 函数去直接创建  Int_interval.t 实例】！！！！！！！！！！ *)


(* 
   使得  Int_interval.t  抽象的做法   【显式接口】

   相当于强制新的 声明了 接口类型
   
module type Interval_intf =
  sig
    type t
    type endpoint
    val create : endpoint -> endpoint -> t
    val is_empty : t -> bool
    val contains : t -> endpoint -> bool
    val intersect : t -> t -> t
  end

*)

module type Interval_intf = sig
  type t
  type endpoint
  val create : endpoint -> endpoint -> t    (* 让 create 入参不再是  Endpoint.t， 而是  endpoint *)
  val is_empty : t -> bool
  val contains : t -> endpoint -> bool
  val intersect : t -> t -> t
end;;


(* 
   重新定义 Make_interval， 并添加 返回类型的  
   

module Make_interval : functor (Endpoint : Comparable) -> Interval_intf
*)
module Make_interval(Endpoint : Comparable) : Interval_intf = struct
  type endpoint = Endpoint.t
  type t = | Interval of Endpoint.t * Endpoint.t
           | Empty

  (** [create low high] creates a new interval from [low] to
      [high].  If [low > high], then the interval is empty *)
  let create low high =    (* 被返回 module 类型 Interval_intf 限定了时  endpoint *)
    if Endpoint.compare low high > 0 then Empty
    else Interval (low,high)

  (** Returns true iff the interval is empty *)
  let is_empty = function
    | Empty -> true
    | Interval _ -> false

  (** [contains t x] returns true iff [x] is contained in the
      interval [t] *)
  let contains t x =    (* 被返回 module 类型 Interval_intf 限定了时  endpoint *)
    match t with
    | Empty -> false
    | Interval (l,h) ->
      Endpoint.compare x l >= 0 && Endpoint.compare x h <= 0

  (** [intersect t1 t2] returns the intersection of the two input
      intervals *)
  let intersect t1 t2 =
    let min x y = if Endpoint.compare x y <= 0 then x else y in
    let max x y = if Endpoint.compare x y >= 0 then x else y in
    match t1,t2 with
    | Empty, _ | _, Empty -> Empty
    | Interval (l1,h1), Interval (l2,h2) ->
      create (max l1 l2) (min h1 h2)

end;;


(* 
*******************************************  
共享限制
*******************************************
*)


(* 
   
最终的模块是抽象的，但不幸的是它太抽象了。特别是，我们还没有公开类型 endpoint ，这意味着我们甚至无法再构造区间:

*)

module Int_interval = Make_interval(Int);;








(* 

因为上面还没有公开  endpoint 类型，所以 直接使用 create endpoint  endpoint 时会报错的

无法将 3  和  4  映射到  endpoint 类型关联起来


Error: This expression has type elt but an expression was expected of type
         Int_interval.endpoint
*)
Int_interval.create 3 4;;


(* 
   
为了解决这个问题，我们需要暴露 endpoint 等于 Int.t （或者更一般地说， Endpoint.t ，其中 Endpoint 是函子的参数）



【实现此目的的一种方法是通过  【共享约束】，它允许您告诉编译器公开给定类型等于某些其他类型的事实】


                          <Module_type> with type <type> = <type'>      或者     <Module_type> with type <type1> = <type1'> and type <type2> = <type2'>

                          module type 新类型 = 旧类型 with type elt = 被指定的类型;;   如：   

                          module type E2 = E1 with type elt = int;;


该表达式的结果是一个经过修改的新签名，以便它公开了这样一个事实：在模块类型内部定义的 type 等于在模块类型外部定义的 type'
*)

module type Int_interval_intf =
Interval_intf with type endpoint = int;;   (* 将 Interval_intf 中的  endpoint 类型 【公开】 为 int *)
(* 
上述类型为：

module type Int_interval_intf =
  sig
    type t
    type endpoint = int
    val create : endpoint -> endpoint -> t
    val is_empty : t -> bool
    val contains : t -> endpoint -> bool
    val intersect : t -> t -> t
  end   
*)



(* 
我们还可以在函子的上下文中使用共享约束。最常见的用例是您想要公开函子生成的模块的某些类型与提供给函子的模块中的类型相关。




【让 入参 和 返参 关联起来：】


当希望  [公开新模块中的类型 endpoint] 和  [作为函子参数的模块 Endpoint 的类型 Endpoint.t]   之间的相等性   (实际上都是  int) 。可以这样做：

*)

module Make_interval(Endpoint : Comparable)  : (Interval_intf with type endpoint = Endpoint.t)   (* 在这里关联起来了 *)

  = struct

    type endpoint = Endpoint.t (* 在这里关联起来了 *)

    type t = | Interval of Endpoint.t * Endpoint.t
             | Empty

    (** [create low high] creates a new interval from [low] to
        [high].  If [low > high], then the interval is empty *)
    let create low high =   (* 被返回 module 类型 Interval_intf 限定了时  endpoint *)
      if Endpoint.compare low high > 0 then Empty
      else Interval (low,high)

    (** Returns true iff the interval is empty *)
    let is_empty = function
      | Empty -> true
      | Interval _ -> false

    (** [contains t x] returns true iff [x] is contained in the
        interval [t] *)
    let contains t x =  (* 被返回 module 类型 Interval_intf 限定了时  endpoint *)
      match t with
      | Empty -> false
      | Interval (l,h) ->
        Endpoint.compare x l >= 0 && Endpoint.compare x h <= 0

    (** [intersect t1 t2] returns the intersection of the two input
        intervals *)
    let intersect t1 t2 =
      let min x y = if Endpoint.compare x y <= 0 then x else y in
      let max x y = if Endpoint.compare x y >= 0 then x else y in
      match t1,t2 with
      | Empty, _ | _, Empty -> Empty
      | Interval (l1,h1), Interval (l2,h2) ->
        create (max l1 l2) (min h1 h2)

  end;;
(* 
上述类型为：

module Make_interval :
  functor (Endpoint : Comparable) ->
    sig
      type t
      type endpoint = Endpoint.t
      val create : endpoint -> endpoint -> t
      val is_empty : t -> bool
      val contains : t -> endpoint -> bool
      val intersect : t -> t -> t
    end   
*)

(* 

现在界面与原来一样，只是 【已知 endpoint 等于 Endpoint.t 。】


由于类型相等，我们可以再次执行需要公开 endpoint 的操作，例如 构造间隔：

*)

module Int_interval = Make_interval(Int);;
(* 
上述类型为：

module Int_interval :
  sig
    type t = Make_interval(Base.Int).t
    type endpoint = int
    val create : endpoint -> endpoint -> t
    val is_empty : t -> bool
    val contains : t -> endpoint -> bool
    val intersect : t -> t -> t
  end
*)


let i = Int_interval.create 3 4;;

Int_interval.contains i 5;;


(* 

共享限制缺点：

特别是，我们现在一直被 endpoint 的无用类型声明所困扰，它使接口和实现都变得混乱。



解决方案：


修改 Interval_intf 签名，在出现的所有位置将 endpoint 替换为 Endpoint.t ，并从签名中删除 endpoint 的定义。 ( 这不又回到 共享限制  前的实现了么 ???  共享实现 就是为了解决它的呀 ！！！ 尼玛)


(----------------- 可以知道， 并不是真正回到  共享限制  前的定义， 而是通过  破坏性替代  来实现的 -----------------)
我们可以使用所谓的破坏性替代来做到这一点。这是基本语法：




              <Module_type> with type <type> := <type'>


              注意， 和 共享限制  语法有轻微差别，等号为  := 

              共享限制语法为： <Module_type> with type <type> = <type'>





*******************************************  
破坏性替代
*******************************************



值得注意的是，这个名字有点误导，因为破坏性替代并没有什么破坏性。这实际上只是一种通过   【改造现有签名 来创建新签名的方法】
*)
module type Int_interval_intf = Interval_intf with type endpoint := int;;

(* 
   
现在没有 endpoint 类型：它的所有出现都已被 int 替换。与共享约束一样，我们也可以在函子的上下文中使用它：

*)

module Make_interval(Endpoint : Comparable)  : Interval_intf with type endpoint := Endpoint.t =
  struct

    type t = | Interval of Endpoint.t * Endpoint.t
             | Empty

    (** [create low high] creates a new interval from [low] to
        [high].  If [low > high], then the interval is empty *)
    let create low high =
      if Endpoint.compare low high > 0 then Empty
      else Interval (low,high)

    (** Returns true iff the interval is empty *)
    let is_empty = function
      | Empty -> true
      | Interval _ -> false

    (** [contains t x] returns true iff [x] is contained in the
        interval [t] *)
    let contains t x =
      match t with
      | Empty -> false
      | Interval (l,h) ->
        Endpoint.compare x l >= 0 && Endpoint.compare x h <= 0

    (** [intersect t1 t2] returns the intersection of the two input
        intervals *)
    let intersect t1 t2 =
      let min x y = if Endpoint.compare x y <= 0 then x else y in
      let max x y = if Endpoint.compare x y >= 0 then x else y in
      match t1,t2 with
      | Empty, _ | _, Empty -> Empty
      | Interval (l1,h1), Interval (l2,h2) ->
        create (max l1 l2) (min h1 h2)

  end;;

(* 
上述类型为：   

module Make_interval :
  functor (Endpoint : Comparable) ->
    sig
      type t
      val create : Endpoint.t -> Endpoint.t -> t
      val is_empty : t -> bool
      val contains : t -> Endpoint.t -> bool
      val intersect : t -> t -> t
    end
*)




(* 
   
到目前为止， 

接口正是我们想要的： 【t 类型是抽象的，端点的类型是公开的】



因此我们可以使用创建函数创建 Int_interval.t 类型的值，但不能直接使用 构造函数  (即 不能 Int_interval.Interval(l, h) 这样用)，从而违反了模块的 不变量。

*)


(* 
module Int_interval :
  sig
    type t = Make_interval(Base.Int).t
    val create : int -> int -> t
    val is_empty : t -> bool
    val contains : t -> int -> bool
    val intersect : t -> t -> t
  end   
*)
module Int_interval = Make_interval(Int);;




Int_interval.is_empty  (Int_interval.create 3 4);;

(* Error: Unbound constructor Int_interval.Interval *)
Int_interval.is_empty (Int_interval.Interval (4,3));;   (* 不能直接使用 构造函数 *)

(* 
   
至此， endpoint 类型已从接口中消失，这意味着我们不再需要在模块主体中定义 endpoint 类型别名。 

*)





(* 
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
*******************************************  
终极例子：        使用多个接口
*******************************************
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------



我们可能希望间隔模块具有的另一个功能是序列化的能力，即能够以字节流的形式读取和写入间隔。


由于 函子 不能和 ppx 一起使用  (是吗 ?????)  (但是貌似  module type  的 sig 中可以由 ppx) 如：

          module type M = sig type t [@@deriving sexp] end;;

*)


(* 如  一般类型和 ppx  *)
type some_type = int * string list [@@deriving sexp];;
(* 
   
type some_type = int * string list
val some_type_of_sexp : Sexp.t -> some_type = <fun>
val sexp_of_some_type : some_type -> Sexp.t = <fun>

*)
sexp_of_some_type (33, ["one"; "two"]);;

Core.Sexp.of_string "(44 (five six))" |> some_type_of_sexp;;


(* 
   将 ppx  放入函子中  会报错 
   
Error: Unbound value Endpoint.t_of_sexp




问题在于 [@@deriving sexp] 添加了用于定义 s 表达式转换器的代码，并且该代码假定 Endpoint 具有适用于 Endpoint.t 的适当的 sexp 转换函数。

但我们对 Endpoint 的了解只是它满足 Comparable 接口，而该接口没有提及任何有关 s 表达式的信息。
*)
module Make_interval(Endpoint : Comparable)
  : (Interval_intf with type endpoint := Endpoint.t) = struct

  type t = | Interval of Endpoint.t * Endpoint.t
           | Empty
  [@@deriving sexp]     (*  【这里是不可行的】  *)

  (** [create low high] creates a new interval from [low] to
      [high].  If [low > high], then the interval is empty *)
  let create low high =
    if Endpoint.compare low high > 0 then Empty
    else Interval (low,high)

  (** Returns true iff the interval is empty *)
  let is_empty = function
    | Empty -> true
    | Interval _ -> false

  (** [contains t x] returns true iff [x] is contained in the
      interval [t] *)
  let contains t x =
    match t with
    | Empty -> false
    | Interval (l,h) ->
      Endpoint.compare x l >= 0 && Endpoint.compare x h <= 0

  (** [intersect t1 t2] returns the intersection of the two input
      intervals *)
  let intersect t1 t2 =
    let min x y = if Endpoint.compare x y <= 0 then x else y in
    let max x y = if Endpoint.compare x y >= 0 then x else y in
    match t1,t2 with
    | Empty, _ | _, Empty -> Empty
    | Interval (l1,h1), Interval (l2,h2) ->
      create (max l1 l2) (min h1 h2)

end;;


(* 

解决：


 Base 的内置接口，称为 Sexpable.S 



 修改 Make_interval 以使用 Sexpable.S 接口，用于其输入和输出。首先，
 
 让我们创建 Interval_intf 接口的扩展版本，其中【包含 Sexpable.S 接口中的功能】。
 
 我们可以在 Sexpable.S 接口上使用破坏性替换来做到这一点，以避免多个不同类型 t 相互冲突：

 对所有包含的接口（包括 Interval_intf ）应用破坏性替换

*)
(* 
module type Interval_intf_with_sexp =
  sig
    type t
    type endpoint
    val create : endpoint -> endpoint -> t
    val is_empty : t -> bool
    val contains : t -> endpoint -> bool
    val intersect : t -> t -> t
    val t_of_sexp : Sexp.t -> t
    val sexp_of_t : t -> Sexp.t
  end   
*)

module type Interval_intf_with_sexp = sig
  type t
  include Interval_intf with type t := t
  include Sexpable.S with type t := t
end;;


(* 

现在编写函子本身，地覆盖了 sexp 转换器，以确保从 s 表达式读取时仍然保持数据结构的不变量：

*)

module Make_interval(Endpoint : sig
  type t
  include Comparable with type t := t
  include Sexpable.S with type t := t
end)
: (Interval_intf_with_sexp with type endpoint := Endpoint.t)
= struct

type t = | Interval of Endpoint.t * Endpoint.t
         | Empty
[@@deriving sexp]

(** [create low high] creates a new interval from [low] to
    [high].  If [low > high], then the interval is empty *)
let create low high =
  if Endpoint.compare low high > 0 then Empty
  else Interval (low,high)

(* put a wrapper around the autogenerated [t_of_sexp] to enforce
   the invariants of the data structure *)
let t_of_sexp sexp =
  match t_of_sexp sexp with
  | Empty -> Empty
  | Interval (x,y) -> create x y

(** Returns true iff the interval is empty *)
let is_empty = function
  | Empty -> true
  | Interval _ -> false

(** [contains t x] returns true iff [x] is contained in the
    interval [t] *)
let contains t x =
  match t with
  | Empty -> false
  | Interval (l,h) ->
    Endpoint.compare x l >= 0 && Endpoint.compare x h <= 0

(** [intersect t1 t2] returns the intersection of the two input
    intervals *)
let intersect t1 t2 =
  let min x y = if Endpoint.compare x y <= 0 then x else y in
  let max x y = if Endpoint.compare x y >= 0 then x else y in
  match t1,t2 with
  | Empty, _ | _, Empty -> Empty
  | Interval (l1,h1), Interval (l2,h2) ->
    create (max l1 l2) (min h1 h2)
end;;
(* 
上述类型为：

module Make_interval :
  functor
    (Endpoint : sig
                  type t
                  val compare : t -> t -> int
                  val t_of_sexp : Sexp.t -> t
                  val sexp_of_t : t -> Sexp.t
                end)
    ->
    sig
      type t
      val create : Endpoint.t -> Endpoint.t -> t
      val is_empty : t -> bool
      val contains : t -> Endpoint.t -> bool
      val intersect : t -> t -> t
      val t_of_sexp : Sexp.t -> t
      val sexp_of_t : t -> Sexp.t
    end
*)

module Int_interval = Make_interval(Int);;
(* 
上述类型为：

module Int_interval :
  sig
    type t = Make_interval(Base.Int).t
    val create : int -> int -> t
    val is_empty : t -> bool
    val contains : t -> int -> bool
    val intersect : t -> t -> t
    val t_of_sexp : Sexp.t -> t
    val sexp_of_t : t -> Sexp.t
  end
*)

Int_interval.sexp_of_t (Int_interval.create 3 4);;

Int_interval.sexp_of_t (Int_interval.create 4 3);;


























