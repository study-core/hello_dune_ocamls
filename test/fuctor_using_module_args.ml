
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




(* 

再细一点的讲解

*)

(* 
  1、定义 functor 的输入和输出接口
*)


(* 1.1、 输入模块的签名：加密算法 *)
module type ALGORITHM = sig
  type t
  val encrypt : t -> string
  val decrypt : string -> t
  val to_string : t -> string
end

(* 1.2、 输出模块的签名：数据处理器 *)
module type PROCESSOR = sig
  type data
  val run : data -> unit
end

(* 1.3、 辅助签名：日志记录器 *)
module type LOGGER = sig
  val log : string -> unit
end


(* 
  2、定义函子的几种方式
*)




(* 2.1、标准命名函子，显式命名 (最常用) *)

(* 因为该 functor 返回的模块为 PROCESSOR 类型，所以在 struct ...end 中的内在和 PROCESSOR 类型的模块的结构是一样的 *)
module MakeProcessor (Algo : ALGORITHM) : (PROCESSOR with type data = Algo.t) = struct
  type data = Algo.t
  
  let run d =
    let cipher = Algo.encrypt d in
    (* 这里只用一个 ; 是因为: 在函数体内部或 let 绑定内部, 它是 【表达式内部】 的胶水，用来连接两个需要顺序执行的动作 *)
    (* 不用 ;; 是因为 ;; 是用来告诉编译器：“这整个定义（如整个函数、整个模块）已经彻底写完了，可以开始编译/求值了 *)
    (* 如果用了 ;; 编译器会认为 run 函数到此就突然结束了，导致后面的 let original 变成一个语法错误的孤立片段 *)
    Printf.printf "MakeProcessor 加密后的数据为: %s\n" cipher;   
    let original = Algo.decrypt cipher in
    (* 这里不用 ; 是因为最后没有语句了已经到了 end 关键字咯 *)
    Printf.printf "MakeProcessor 数据已安全还原，原始值为: %s\n" (Algo.to_string original)
end

(* 使用：传入具体的 Int 算法模块 *)
module IntAlgo = struct
  type t = int
  let encrypt n = string_of_int (n + 100)
  let decrypt s = int_of_string s - 100
  let to_string = string_of_int
end

module IntProcessor = MakeProcessor(IntAlgo)
let () = IntProcessor.run 42






(* 2.2、 使用 functor 关键字 (显式函数式定义) *)

(* 
    直接定义 functor，不用先定义 functor 长什么样，而再去实现它

    查看和 2.3 的区别  
*)


(* 直接定义 functor *)
module MakeProcessorAlt = functor (Algo : ALGORITHM) -> struct
  type data = Algo.t
  let run d = 
    let cipher = Algo.encrypt d in 
    Printf.printf "MakeProcessorAlt 加密后的数据为: %s\n" cipher
end

module IntProcAlt = MakeProcessorAlt(IntAlgo)
let () = IntProcAlt.run 42

(* 2.3、 函子签名定义 (Functor Type / Interface) *)
(* 
    先定义 functor 长什么样，再去实现它

              (* 声明一个函子的类型（即函子的签名） *)
              module type SET_MAKER = functor (Elt : Comparable) -> Set_S with type elt = Elt.t
              
              (* 实现该类型的函子 *)
              module MakeSet : SET_MAKER = functor (Elt : Comparable) -> struct
                (* ... *)
              end

    查看和 2.2 的区别          
*)

(* 声明 functor 类型:   接受 ALGORITHM 类型的模块, 返回 PROCESSOR 类型的模块 *)
module type PROCESSOR_MAKER_SIG = functor (Algo : ALGORITHM) -> PROCESSOR with type data = Algo.t
(* 定义 functor *)
module MakeProcessorFunctor : PROCESSOR_MAKER_SIG = functor (Algo : ALGORITHM) -> struct
  type data = Algo.t
  let run d = 
    let cipher = Algo.encrypt d in 
    Printf.printf "MakeProcessorFunctor 加密后的数据为: %s\n" cipher
end

module IntProcAlt = MakeProcessorFunctor(IntAlgo)
let () = IntProcAlt.run 42


(* 或者  将具体的函子赋值给该类型 *)
module Factory : PROCESSOR_MAKER_SIG = MakeProcessor

(* 使用时先传入算法模块，再获取处理器 *)
module MyProcessor = Factory(IntAlgo)
let () = MyProcessor.run 42







(* 2.4、 多参数（柯里化）函子 (Curried Functors) *)
(* 
    入参分别为 Algo 和 Log 
    
            module Join (M1 : S1) (M2 : S2) = struct
              (* 同时使用 M1 和 M2 的内容 *)
            end
            
            (* 等价于嵌套写法 *)
            module Join (M1 : S1) = struct
              module Inner (M2 : S2) = struct
                (* ... *)
              end
            end  
*)
module SecureLogger (Algo : ALGORITHM) (Log : LOGGER) = struct
  let process d =
    Log.log "Starting...";
    let _ = Algo.encrypt d in
    Log.log "Finished."
end

(* 具体实现日志模块 *)
module StdoutLogger = struct
  let log = print_endline
end

(* 应用时依次传入两个模块 *)
module MySecureLog = SecureLogger(IntAlgo)(StdoutLogger)
let () = MySecureLog.process 100






(* 2.5、 第一类模块中的函子 (第一类模块包裹函子，将函子打包成一个 “值”) *)
(* 
    将函子打包成一个 “值”，然后作为函数参数传递给其他函数，在运行时应用它

              (* 将函子打包成第一类模块值 *)
              let my_functor_value = (module Make : functor (M : S) -> OUT_S)
              
              (* 解包并应用 *)
              module NewM = (val my_functor_value : functor (M : S) -> OUT_S) (ActualM)
              
              *)

(* 1. 打包函子     使用  打包 第一类模块 的语法 *)
let my_f_value : (module PROCESSOR_MAKER_SIG) = (module MakeProcessor)

(* 2. 动态使用：接收一个函子“值” 作为函数参数，并在运行时应用它 *)
let run_dynamic (type a) (module F : PROCESSOR_MAKER_SIG) (module A : ALGORITHM with type t = a) (data : a) =
  (* 解包函子并应用它 *)
  let module P = F(A) in
  P.run data

let () = run_dynamic my_f_value (module IntAlgo) 99








(* 2.6、 使用 【破坏性替换】 *)
(* 
              module Make (M : sig type t end) : S with type elt := M.t = struct
                (* 这里 elt 被彻底替换为 M.t，外部看不到 elt 这个名字 *)
              end
*)
module CleanProcessor (Algo : ALGORITHM) : (PROCESSOR with type data := Algo.t) = struct
  let run d = 
    let _ = Algo.encrypt d in 
    print_endline "Clean running..."
end

(* 生成的模块签名直接变为：val run : int -> unit *)
module IntCleanProc = CleanProcessor(IntAlgo)
let () = IntCleanProc.run 7







(* 2.7、 使用 匿名参数 *)
(* 
    直接将 functor 签名出来，而不是实现定义， 是临时定义

            module Make (M : sig val x : int end) = struct
              let y = M.x + 1
            end
*)
module Simple (M : sig val x : int end) = struct
  let result = M.x * 2
end

module Six = Simple(struct let x = 3 end)

let () = Printf.printf "Six = %d\n" Six.result







(* 
  2.8、 生成函子的函子 (Higher-order Functors)

  高阶 functor： 函子可以接收另一个函子作为参数，或者返回一个函子

            module Transform (F : SET_MAKER) (E : Comparable) = struct
              (* 使用 函子 F 和 模块 E 生成一个 新模块 S *)
              module S = F(E)
              (* 对生成的新模块进行进一步转换 *)
            end

  等价于 （柯里化 functor）
  
            module Transform (F : SET_MAKER) = struct
              (* 返回一个新的函子，它接收 E *)
              module Make (E : Comparable) = struct
                (* 使用 函子 F 和 模块 E 生成一个 新模块 S *)
                module S = F(E)
                (* ...扩展逻辑... *)
              end
            end
*)

(* 定义基础模块签名： 可比较的类型 和 集合类型 *)
module type Comparable = sig type t val compare : t -> t -> int end
module type SET = sig type elt val add : elt -> unit end

(* 定义函子类型 *)
module type SET_MAKER = functor (E : Comparable) -> SET with type elt = E.t

(* 定义高阶函子：它接收一个“工厂” F 和一个“零件” E *)
module Transform1 (F : SET_MAKER) (E : Comparable) = struct
  (* 关键点：在函子内部应用传入的函子参数 *)
  (* 该函子生成的新模块将具备 子模块 S *)
  module S = F(E)
  
   (* 该函子生成的新模块将具备 add_with_log 函数 *)
  let add_with_log x =
    print_endline "Adding element...";
    S.add x
end

(* 定义基础模块：整数比较器 *)
module IntCompare = struct
  type t = int
  let compare = Int.compare
end

(* 定义基础函子：一个简单的列表集合生成器 *)
module ListSetMaker : SET_MAKER = functor (E : Comparable) -> struct
  type elt = E.t
  let add _x = print_endline "Item added to ListSet 1"
end

(* 使用 *)
module EnhancedIntSet = Transform1(ListSetMaker)(IntCompare)
let () = EnhancedIntSet.S.add 42;





(* 

又如:

*)






(* 1. 定义高阶函子的签名：输入一个 functor，返回一个增强版 functor *)
module type TRANSFORMER = 
functor (F : SET_MAKER) -> 
  functor (E : Comparable) -> SET with type elt = E.t

(* 2. 实现这个高阶函子，入参为 函子类型 SET_MAKER 返参为 (入参是模块类型 Comparable 的新函子)的高阶函子*)
module Transform2 : TRANSFORMER = 
functor (F : SET_MAKER) -> 
  functor (E : Comparable) -> struct
    module S = F(E)
    type elt = S.elt
    let add x = print_endline "Log"; S.add x
  end

(* 3. 定义基础模块：整数比较器 *)
module IntCompare = struct
  type t = int
  let compare = Int.compare
end

(* 4. 定义基础函子：一个简单的列表集合生成器 *)
module ListSetMaker : SET_MAKER = functor (E : Comparable) -> struct
  type elt = E.t
  let add _x = print_endline "Item added to ListSet 2"
end

(* 5. 使用高阶函子 *)
(* 第一步：把基础 functor 传给高阶函子 Transform2，得到一个 “增强型 functor” LoggedSetMaker  *)
module LoggedSetMaker = Transform2(ListSetMaker)
(* 第二步：用这个 “增强型 functor” LoggedSetMaker 配合 “整数比较器” IntCompare 模块生成最终模块 MyLoggedIntSet *)
module MyLoggedIntSet = LoggedSetMaker(IntCompare)
(* 测试调用 *)
let () = MyLoggedIntSet.add 42
(* 
  输出：
    Log
    Item added to ListSet 
*)



(* 

又如:

*)

(* 模块签名  ALGO*)
module type ALGO = sig val run : string -> string end
(* 函子签名 MAKER, 该 functor 入参为  ALGO 类型的 模块 *)
module type MAKER = functor (A : ALGO) -> sig val execute : string -> unit end

(* 实现签名为 MAKER 的函子 MakeExec *)
module MakeExec (A : ALGO) = struct
  let execute s = print_endline (A.run s)
end

(* --- 场景 A (演示 入参函子和模块的高阶函子)：高阶函子 (编译时组合) --- *)
(* 定义高阶函子 MetaFactory，入参为类型 MAKER 的函子  和类型为 ALGO 的模块 *)
module MetaFactory (F : MAKER) (A : ALGO) = struct
  module Final = F(A) (* 在这里静态地组合了两个模块 *)
end






(* --- 场景 B (演示 入参函子打包的第一模块和模块打包的第一模块的 函数)：第一类模块 (运行时动态) --- *)
(* 定义 函数 dynamic_dispatch，入参为 类型为 MAKER 的函子(打包的)第一类模块 和 类型为 ALGO 的模块(打包的)第一类模块 *)
let dynamic_dispatch (f_val : (module MAKER)) (a_val : (module ALGO)) =
  (* 解包第一类模块 f_val 为 F 函子 *)
  let module F = (val f_val : MAKER) in
  (* 解包第一类模块 a_val 为 A 模块 *)
  let module A = (val a_val : ALGO) in
  (* 使用 F 函子 和 A 模块 生成一个 新的模块 Res *)
  let module Res = F(A) in
  Res.execute "hello gavin"



(* 1. 实现一个具体的算法模块 *)
module UpperAlgo = struct
  let run s = String.uppercase_ascii s
end



(* --- 场景 A：测试高阶函子 (编译时) --- *)
(* 我们调用高阶函子 MetaFactory 使用参数为函子 MakeExec 和算法模块 UpperAlgo *)
module MyMeta = MetaFactory(MakeExec)(UpperAlgo)

let () = 
  print_endline "--- 场景 A 打印 ---";
  (* 调用生成的新模块 MyMeta 的子模块 Final 模块的 execute 函数，入参为 "hello world" *)
  MyMeta.Final.execute "hello world"
  (* 打印结果: HELLO WORLD *)


(* --- 场景 B：测试第一类模块 (运行时) --- *)
let () =
  print_endline "--- 场景 B 打印 ---";
  
  (* 打包阶段：将静态的函子和模块转换为“值” *)
  let f_value = (module MakeExec : MAKER) in
  let a_value = (module UpperAlgo : ALGO) in
  
  (* 调用动态分发函数 *)
  dynamic_dispatch f_value a_value
  (* 打印结果: hello (由 Res.execute "hello" 产生) *)


