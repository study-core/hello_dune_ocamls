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

    module 名称 (参数名称 : 签名表达式) = 模块化表达式

    以下糖衣语法

    module 名称 = functor (参数名称 : 签名表达式) -> 模块化表达式   
*)

(* 
    签名定义
    module type ELEMENT = sig type t val compare : t -> t -> int end
*)
module type ELEMENT = sig
  type t
  val compare: t -> t -> int
end

(* 
    functor

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