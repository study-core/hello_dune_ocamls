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
    type t = int
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
    type t = String
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
显式 指定某个 sig 中的字段值并生成新字段      
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
           