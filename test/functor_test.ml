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

    【函数器】本质上是根据其他模块编写模块的一种方式

    【仿函数】是一个由【另一个模块】参数化的模块，
    就像【函数】是一个由【其他值】（参数）参数化的值一样

    module 名称 (参数名称 : 签名表达式) = 模块化表达式

    以下糖衣语法

    module 名称 = functor (参数名称 : 签名表达式) -> 模块化表达式   
*)


(* ----------------------------------------------------------------------------------------- *)
(* -------------------------------- 【不】具备返回值的写法  -------------------------------- *)

(* 
    签名定义  (也是 命名模块类型 (模块类型定义))
    (查看 module_test.ml 文件对比)
    module type ELEMENT = sig type t val compare : t -> t -> int end
*)
module type ELEMENT = sig
  type t
  val compare: t -> t -> int
end

(* 
    functor

    语法： 
    (* X 是将作为参数传递的模块， X_type 是它的签名 *)
    module F (X : X_type) = struct   
      ...
    end

    或者

    module F (X : X_type) : Y_type = struct
      ...
    end

    或者 通过在 .mli 文件中指定：

    module F (X : X_type) : Y_type

    如：

    module MakeSet : functor (Element : ELEMENT) ->
      sig
        type elt = Element.t
        type t = elt list
        val empty : 'a list
        val mem : Element.t -> Element.t list -> bool
        val add : Element.t -> Element.t list -> Element.t list
        val elements : 'a -> 'a
      end
定义 *)
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
        (* 如果 不等于 首元素 且 < 0 则加到 list 尾部 *)
        | r when r < 0 -> elt :: s
        (* 否则，对比 list 下一个 元素 *)
        | _ -> x :: (add elt rest)

    let rec elements s = s
  end;;



(* 
    使用， 则
    module StringSet :
      sig
        type elt = String.t
        type t = elt list
        val empty : 'a list
        val mem : String.t -> String.t list -> bool
        val add : String.t -> String.t list -> String.t list
        val elements : 'a -> 'a
      end 
*)
module StringSet = MakeSet(String);;


(* ----------------------------------------------------------------------------------------- *)
(* -----------------------------------  具备返回值的写法 ----------------------------------- *)

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
    使用，则
    module IntSet :
      sig
        type elt = int
        type t (* 抽象数据类型 *)
        val empty : t
        val mem : elt -> t -> bool
        val add : elt -> t -> t
        val elements : t -> elt list
      end
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
    当它是一个字符串
    module StringSet :
      sig
        type elt = String.t
        type t = MakeSet(String).t (* 有隐藏的实现吗？ *)
        val empty : t
        val mem : elt -> t -> bool
        val add : elt -> t -> t
        val elements : t -> elt list
      end
*)
module StringSet = MakeSet(String);;

(* 
    val s1 : StringSet.t = <abstr> (* 这是一个抽象的数据类型 *)
    val s2 : StringSet.t = <abstr>
*)
open StringSet;;
let s1 = add "a" (add "b" empty) and s2 = add "c" (add "d" empty);;



(* ----------------------------------------------------------------------------------------- *)
(* ------------------------- 显示指定某个 sig 中的字段值并生成新字段 ----------------------- *)

module type E1 =
    sig
      type elt
      type t
      val empty : t
      val mem : elt -> t -> bool
      val add : elt -> t -> t
      val elements : t -> elt list
    end;;

(* with type 指定 E1 的 elt 字段并定义 E2 *)
(* 
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
