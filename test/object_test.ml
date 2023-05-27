(* 实例变量的所有成员都是私有的 *)
(* 
  (* 签名 *)    
  class point :
    int ->
    int ->
    object
      val mutable x : int
      val mutable y : int
      method private print_x : unit
      method set : int -> int -> unit
    end   
*)
class point ini_x ini_y =
    object (self)  (* self  this 随便命名 *)
      val mutable x = 0 (* 实例变量不能从外部访问 *)
      val mutable y = 0

      (*
       * 实例方法
       * method 方法名称 参数... = 表达式
       *)
      method set new_x new_y = begin x <- new_x; y <- new_y end
      method private print_x = print_int x (* 私有方法 *)

      (* 构造函数 *)
      initializer begin
        x <- ini_x; y <- ini_y
      end
    end;;


(* 
      val p : point = <obj>
*)
let p = new point;;


(* - : unit = () *)
p#set 1 2;;

(* ----------------------------------------------------------------------------------------- *)
(* ------------------------------------------ 继 承 ---------------------------------------- *)

(* 
    class point_with_print :
      int ->
      int ->
      object
        val mutable x : int
        val mutable y : int
        method print : unit
        method private print_x : unit
        method set : int -> int -> unit
      end
*)
class point_with_print x y =
    object (self)
      inherit point x y as super (* 访问父类的名称 *)
      method print = Printf.printf "(%d, %d)\n" x y
    end;;


(* 生成继承类的实例 *)
(* 
    val p : point_with_print = <obj>
*)
let p = new point_with_print 1 1;;

(* 
    (1, 1)
    - : unit = ()
*)
# p#print;;


(* ----------------------------------------------------------------------------------------- *)
(* --------------------------------------- Object 类型 ------------------------------------- *)

(* 直接定义对象 *)
(* 
    (* 显示类型 *)
    val obj : < set : int -> int -> unit > = <obj>    

    注意: 具有满足这个定义的方法的类被认为是相同的对象类型
*)
let obj = 
  object (self)
    val mutable x = 0
    val mutable y = 0
    method set new_x new_y = begin x <- new_x; y <- new_y end
  end;;


(* 尝试调用实例方法 *)
(* - : unit = () *)
obj#set 1 2;;


(* 定义上面与obj无关的类 *)
(* 
    class unrelated_class : object method set : int -> int -> unit end   
*)
class unrelated_class =
    object
      (* 定义一个显示x，y的方法集 *)
      method set x y = Printf.printf "(%d, %d)\n" x y
    end;;



(* 
    由于对象类型匹配，它们被放在同一个列表中
    val obj2 : unrelated_class = <obj>
*)
let obj2 = new unrelated_class;;


(* 
      - : unrelated_class list = [<obj>; <obj>]

      直接定义的额 obj  和 使用 class 定义的 obj2 由于类型一致:
      都具备 方法:  set : int -> int -> unit end   
      故被认为是相同的对象类型
      可以放到同一个 list 中
*)
[obj; obj2];;


(* 
    由于对象类型匹配，可以将其作为相同的返回值类型进行处理

    val hoge : bool -> unrelated_class = <fun>
*)
let hoge x = if x then obj else new unrelated_class;;

(* 
    obj#set
    - : unit = ()
*)
(hoge true)#set 1 2;;

(* 
      unrelated_class#set
      (1, 2)
      - : unit = ()
*)
(hoge false)#set 1 2;;



(* ----------------------------------------------------------------------------------------- *)
(* ---------------------------------------- 部分 类型 -------------------------------------- *)



(* print_class1 是 print_class2 的部分类型 *)

(* 
      class print_class1 : object method print_1 : unit end
*)
class print_class1 = object
  method print_1 = print_int 1
end;;



(* 
    class print_class2 : object method print_1 : unit method print_2 : unit end   
*)
class print_class2 = object
  method print_1 = print_int 1
  method print_2 = print_int 2
end;;


(* 由于对象类型不同，print_class 1和print_class 2不在同一个列表中 *)
(* 
    Error: This expression has type print_class2
           but an expression was expected of type print_class1
           The second object type has no method print_2   
*)
let obj_list = [new print_class1; new print_class2];;



(* 
    通过指导（类型转换）把它们放在同一个列表中

    A :> B ==》 类型 A 实例 转化为 类型 B 实例
*)
(* 
    val obj_list : print_class1 list = [<obj>; <obj>]   
*)
let obj_list = [new print_class1; (new print_class2 :> print_class1)];;


(* 不能调用由复制操作之后 而被删除 的信息 *)
(* 
    val obj1 : print_class1 = <obj>
    val obj2 : print_class1 = <obj>   
*)
let [obj1; obj2] = obj_list;;


(* 1- : unit = () *)
obj1#print_1;; (* 可以调用 *)


(* 
      Error: This expression has type print_class1
      It has no method print_2   
*)
obj2#print_2;; (* 不能被调用 *)



(* ----------------------------------------------------------------------------------------- *)
(* ---------------------------------------- 部分 类型 -------------------------------------- *)


(* 定义接受多层对象类型的函数 *)
(* 
    val print1 : < print_1 : 'a; .. > -> 'a = <fun>   

    以上 < print_1 : 'a; … > -> 'a = 中的 -> 'a 部分 'a 是一个类型变量 < print_1 : 'a; … > 的别名
*)
let print1 print_obj = print_obj#print_1;;


(* 您可以接收满足部分类型的对象类型 *)
(* 1- : unit = () *)
print1 obj1;;

(* 1- : unit = () *)
print1 obj2;;



(* ----------------------------------------------------------------------------------------- *)
(* ------------------------------------- 多阶段类（泛型） ---------------------------------- *)


(* 
    class ['a] stack :
      object
        val mutable list : 'a list
        method peek : 'a
        method pop : 'a
        method push : 'a -> unit
        method size : int
      end   
*)

class ['a] stack =
    object (self)
      val mutable list = ( [] : 'a list )  (* 实例变量 *)
      method push x = list <- x :: list    (* 推入堆栈 *)
      method pop =                         (* 从堆栈中移除(pop) *)
        let result = List.hd list in
        list <- List.tl list;
        result
      method peek = List.hd list     (* 堆栈峰值 *)
      method size = List.length list (* 堆栈的大小 *)
    end;;
