(* 

单子

"monad" 这个名字来自范畴论的数学领域，它研究数学结构的抽象。

Monad 通过在 Haskell 中的使用而在编程世界中流行起来, Haskell 开始通过 monad 设计模式来 【避免副作用】 的使用。   


Monad 用于模拟计算。将计算视为一个函数，它将输入映射到输出，但也做“更多事情”。






但任何实用语言都不可能没有副作用。毕竟，打印到屏幕是一个副作用。因此 Haskell 开始通过 monad 设计模式来 【控制副作用】 的使用。




【单子】是满足两个属性的结构。首先，它必须匹配以下签名：   

  1. unit :: t -> M t, 将类型 T 包装 成 Monad 类型, 也被常常称为 return/pure/lift 操作.

  2. bind :: M a -> (a -> M b) -> M b, bind 组合子, 输入一个 M a 和 一个 func 然后返回 M b (输入的函数可以拿到 被包装 的类型 a, 进行变换返回M b). 
    这个操作定义了二元操作符，在 haskell 里用 >>= 操作符表示.


这两个操作可以这样理解：

  定义个 Monad 类型用于 包裹 另一个类型 T，
  同时定义一个二元操作，左边对象是个 Monad<T>，右边对象是个函数接受被包裹的 T 值并返回一个 Monad<U> 对象，

这样就能不断通过这个二元操作串起来。    
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




(* 


Rust 的 Option 其实做的相当完备，我们看看其定义：   【故 Rust 的 Option 其实就是 Monad 啦】

enum Option<T> {
    None,
    Some(T),
}
和关键的 Monad 操作：
      
      1. None/Some<T>提供了将值包装成 Option<T> 的可能，即 unit 操作
      
      2. fn and_then<U, F>(self, f: F) -> Option<U>实现了二元操作，即 bind 操作

fn sq(x: u32) -> Option<u32> { Some(x * x) }
fn nope(_: u32) -> Option<u32> { None }

assert_eq!(Some(2).and_then(sq).and_then(sq), Some(16)); // 串联操作
assert_eq!(Some(2).and_then(sq).and_then(nope), None);
assert_eq!(Some(2).and_then(nope).and_then(sq), None); // 串联操作，避免判断 None
assert_eq!(None.and_then(sq).and_then(sq), None);      

*)