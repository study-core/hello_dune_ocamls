(* 
“monad”这个名字来自范畴论的数学领域，它研究数学结构的抽象。
Monad 通过在 Haskell 中的使用而在编程世界中流行起来, Haskell 开始通过 monad 设计模式来控制副作用的使用。   
Monad 用于模拟计算。将计算视为一个函数，它将输入映射到输出，但也做“更多事情”。
*)

(* 
单子是满足两个属性的结构。首先，它必须匹配以下签名：   
*)

module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end



(* https://cs3110.github.io/textbook/chapters/ds/monads.html *)



(* 
   
【单子】   其 函数式 可非常直接地书写运算，无需样板代码。

          单体允许我们抽象上升到更高的运算，同时提供胶水函数。
          
          换句话说，单体是     【可编程的分号】。
           
          
*)


(* 

例如，下列命令式运算：

function example(x) {
   if ( x == null ) return null;
    x = x + 1;
   if ( !isEven(x) ) return null;
    return x;
  }

我们需要修改成  【单子】 的形式

*)
(* type a' option =
   | None
   | Some of 'a *)
   

let return x = Some x
  
(* 绑定中缀运算，将f应用于m *)
let (>>=) m f =
 match m with
 | Some x -> f x
 | None  -> None
(**
Map 中缀运算

本质上与bind相同，但内部函数会打开值。
 **)
let (>>|) m f = m >>= (fun x -> return (f x))

let add_one = ((+) 1)
  
let bind_even : int -> int option = fun x -> if x mod 2 = 0 then Some x else None
 

let example x = x >>| add_one >>= bind_even;;

(* OCaml有一个“ppx”，使用let语法可以更容易地编写 monad *)

let%bind x = y in

f x

(* 这可归结为以下内容 *)
y >>= (fun x -> f x)

(* 本质上，这个语法是从let语句取值，放在 bind-infix-call 函数式左侧，将赋值插入lambda表达式 *)
