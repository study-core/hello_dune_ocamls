
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



(* 这会将模块 AR 转换为一个值并将其绑定到变量 a *)
let a = (module AR : Arity)   (* this is first-class module *)


(* 提供签名 Arity, 则也可以这样写 *)
let a' : (module Arity) = (module AR)  (* a' 和 a 含义等效的，即:  a 和 a' 的类型是 (模块 Arity) *)

(* 您可以按如下方式将该值返回到模块： *)
module A' = (val a) (* convert module A' from the first-class module a *)


(* -----------------------  现在您还可以创建函子 S 的  first-class module ----------------------- *)



(* 首先定义需要生成的 module 的 sig 类型 *)
module type RESULT = sig
  val check : bool
end

(* s 的作用是：取一个值，将其返回到模块，对其应用函子 S，然后从函子应用的结果中生成另一个值。
   
  签名 RESULT 对于转换是必需的。您不能写入 (module SA：sig val check bool end) 
  
  原因: first-class module 值的​​输入不是结构性的，而是名义上的。您需要为  (module M : X)  处的签名命名

*)


(* 定义函数  s 入参 a 的类型是 一个 first-class module  <看上面的 a' 定义的写法，就知道 a 这里为什么写成 a : (module Arity) > *)
let s (a : (module Arity)) = 

  (* 将 first-class module a 转换回 module A   <其中 A 的签名类型为 Arity>*)
  let module A = (val a) in

  (* 使用 函子 S 得到新 module SA *)
  let module SA = S(A) in

  (* 这一句, 表示 返回一个  first-class module  <看上面 a 定义的写法> *)
  (module SA : RESULT)


(* s 函数的类型是 (module Arity) -> (module RESULT)。让我们将 s 应用于 a *)

(* 此处的 m 是一个 first-class module *)
let m = s a


(* 要访问 m 内部的 check，您需要将其恢复为模块 *)
let call_m_check_result =

  (* 将 first-class module m 转换回 module M *)
  let module M = (val m) in
  M.check  (* 调用 module M 的 check 函数 *)


(* 您可能会失望地看到 value<->module 转换是显式的，但这就是它的工作原理 ...... *)


let () = Printf.printf "%b\n" call_m_check_result   (* false *) 