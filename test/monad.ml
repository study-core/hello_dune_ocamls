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