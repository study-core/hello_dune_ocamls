(* 

单子

处理“副作用”和“上下文”的工程标准

Monad 通过在 Haskell 中的使用而在编程世界中流行起来, Haskell 开始通过 monad 设计模式来 【避免副作用】 的使用。   


Monad 用于模拟计算。将计算视为一个函数，它将输入映射到输出，但也做“更多事情”。






但任何实用语言都不可能没有副作用。毕竟，打印到屏幕是一个副作用。因此 Haskell 开始通过 monad 设计模式来 【控制副作用】 的使用。




【单子】是满足两个属性的结构。首先，它必须匹配以下签名：   

  1. val return : 'a -> 'a t
    
    将类型 T 包装 成 Monad 类型, 也被常常称为 return/pure/lift 操作. 即: 把一个普通值包装到容器里

  2. val bind : 'a t -> ('a -> 'b t) -> 'b t
    
    bind 组合子, 输入一个 M a 和 一个 func 然后返回 M b (输入的函数可以拿到 被包装 的类型 a, 进行变换返回 M b). 
    即: 把一个容器里的值取出来，传给下一个返回容器的函数.
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
  
(* 绑定中缀运算，将f应用于 m *)
let (>>=) m f =
 match m with
 | Some x -> f x
 | None  -> None
(**
 新定义一个 >>| 函数， 入参为类型 m 和 函数 f
 其中使用了 Monad 的 bind 操作，将 m 的值取出来，传给 f 函数，然后使用 return 操作返回 f 函数的返回值
 **)
let (>>|) m f = m >>= (fun x -> return (f x))

(* 函数 add_one 的类型为 int -> int *)
let add_one = ((+) 1)
(* 函数 bind_even 的类型为 int -> int option *)
let bind_even : int -> int option = fun x -> if x mod 2 = 0 then Some x else None
(* 函数 example 的类型为 int option -> int option *)
let example x = x >>| add_one >>= bind_even;;

(* OCaml 4.08 版本引入的一项重大语法特性，旨在提供一种原生、无需 PPX 插件的方式来编写 Monad 代码 *)


(* 它是 bind 的糖 *)
(* 编译器理解为: ( let* ) m (fun x -> f x) , 逻辑上完全等同于经典的 m >>= (fun x -> f x)*)

(* option 的 Monad 使用 *)
(* 1. 必须先定义这个操作符的逻辑 *)
let ( let* ) m f =
  match m with
  | Some x -> f x
  | None -> None

(* 2. 定义 return 操作 *)
let return x = Some x

(* 3. 现在你可以使用它了 *)
let example m =
  let* x = m in
  Some (x + 1)

(* result 的 Monad 使用 *)
(* 1. 必须先定义这个操作符的逻辑 *)
let ( let* ) m f =
  match m with
  | Ok x -> f x
  | Error e -> Error e

(* 2. 定义 return 操作：将普通值包装成 Ok *)
let return x = Ok x

(* 3. 现在你可以使用它了 *)
let example m =
  let* x = m in
  Ok (x + 1)



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


(* 
 又如： 
*)

(* ==========================================
   第一部分：定义 Monad 基础设施
   ========================================== *)

(* 定义返回类型：要么成功(Ok)，要么失败(Error) *)
type ('a, 'e) result = 
  | Ok of 'a 
  | Error of 'e

(* 定义 Monad 的核心：bind 操作符 let* *)
(* 它的逻辑：如果是 Ok 就把里面的值取出来传给下一个函数 f；如果是 Error 就直接中断 *)
let ( let* ) m f =
  match m with
  | Ok x -> f x
  | Error e -> Error e

(* 定义 return：将普通值包装进 Ok 容器 *)
let return x = Ok x

(* ==========================================
   第二部分：定义具体的业务逻辑函数
   ========================================== *)

(* check_age: 输入整数，返回一个 Result 单子 *)
let check_age age =
  if age >= 18 then 
    Ok age  (* 成功，包装在 Ok 中 *)
  else 
    Error "年龄太小，未成年人无法注册" (* 失败，包装在 Error 中 *)

(* check_name: 输入字符串，返回一个 Result 单子 *)
let check_name name =
  if String.length name >= 3 then 
    Ok name 
  else 
    Error "用户名太短，至少需要3个字符"

(* ==========================================
   第三部分：使用 Monad 串联流程 (核心在此)
   ========================================== *)

let register_user age name =
  (* 
     这里的 let* 做了两件事：
     1. 调用 check_age age，得到一个 Ok 18 或者 Error "..."
     2. 如果是 Ok 18，它会自动把里面的 18 提取出来，赋值给 valid_age。
     3. 如果是 Error，后面的代码根本不会执行，整个函数直接返回那个 Error。
  *)
  let* valid_age = check_age age in      (* <-- valid_age 在这里诞生 *)
  let* valid_name = check_name name in    (* <-- valid_name 在这里诞生 *)
  
  (* 到达这一行，说明上面全部成功了 *)
  return (Printf.sprintf "注册成功：用户 %s，年龄 %d" valid_name valid_age)

(* ==========================================
   第四部分：测试与打印结果
   ========================================== *)

let test age name =
  match register_user age name with
  | Ok msg -> Printf.printf "【成功】%s\n" msg
  | Error err -> Printf.printf "【失败】原因：%s\n" err

(* ==========================================
   示例：如何使用上面的函数
   ========================================== *)

(* 使用示例函数 *)
let run_examples () =
  test 20 "Alice";  (* 预期：成功 *)
  test 16 "Bob";    (* 预期：失败（年龄） *)
  test 25 "Li";     (* 预期：失败（名字） *)



(* 

如果不用 Monad 那就会出现称为 “阶梯式代码” 或 “金字塔噩梦”

(* ❌ 不用 Monad 的写法：代码不断向右缩进 *)
let register_user_manual age name =
  (* 第一步：手动拆开 age 的盒子 *)
  match check_age age with
  | Error err -> Error err  (* 如果出错，手动转发错误 *)
  | Ok valid_age ->         (* 如果成功，拿到里面的整数 valid_age *)
      
      (* 第二步：嵌套手动拆开 name 的盒子 *)
      match check_name name with
      | Error err -> Error err  (* 如果出错，再次手动转发错误 *)
      | Ok valid_name ->        (* 如果成功，拿到里面的字符串 valid_name *)
          
          (* 第三步：终于拿到了两个值，手动包装结果 *)
          Ok (Printf.sprintf "注册成功：用户 %s，年龄 %d" valid_name valid_age)

*)
