
(* 定义 module 签名类型 Arity *)
module type Arity = sig
  val arity :int
end


(* 定义 函子 S        --------        参数为  module Arity *)
module S = functor (A : Arity) -> struct
  let check = A.arity = 2 (* or whatever *)
end




(* 定义 module AR *)
module AR: Arity = struct
  let arity = 3
end


(* 使用 函子 S 得到新 module SAR *)
module SAR = S(AR)

let () = Printf.printf "%b\n" SAR.check   (* false *)


(* 定义 module AR *)
module AR2: Arity = struct
  let arity = 2
end


(* 使用 函子 S *)
module SAR2 = S(AR2)

let () = Printf.printf "%b\n" SAR2.check   (* true *)