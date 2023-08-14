(* 
********************************************************************   
实例变量的所有成员都是私有的 
********************************************************************
*)



(* 
  class 的类型:    

######################################################################################################################################################
  class point :
    int ->
    int ->
    object
      val mutable x : int
      val mutable y : int
      method private print_x : unit
      method set : int -> int -> unit
    end  
######################################################################################################################################################    
    
*)
class point ini_x ini_y =

    object (self)  (* self  this 随便命名 *)
      val mutable x = 0 (* 实例变量不能从外部访问 *)
      val mutable y = 0

      (*
       * 实例方法
       * method 方法名称 参数... = 表达式
       *)
      (* method set new_x new_y = begin x <- new_x; y <- new_y end *)
      method set new_x new_y = (x <- new_x; y <- new_y)
      method private print_x = print_int x (* 私有方法 *)

      (* 构造函数 *)
      initializer (
        x <- ini_x; y <- ini_y
      )
    end;;


(* 
      val p : point = <obj>
*)
let p = new point 0 0;;


(* - : unit = () *)
p#set 1 2;;



(* 
######################################################################################################################################################
继 承
######################################################################################################################################################
*)


(* 

    class 的类型: 

######################################################################################################################################################    
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
######################################################################################################################################################

*)

class point_with_print x y =
    object (self)
      inherit point x y as super (* 访问父类的名称 *)
      method print = Printf.printf "(%d, %d)\n" x y
    end;;


(* 
    val p : point_with_print = <obj>
*)
let p = new point_with_print 1 1;;

(* - : unit = () *)
p#print;;



(* 
######################################################################################################################################################
Object 类型   用于直接定义 object  类似 scala 中的 object
######################################################################################################################################################
*)



(* 

********************************************************************
********************************************************************
可以使用 object 代替 record
********************************************************************
********************************************************************

class 不能使用类型递归定义, 但 object 的类型与 record 类型非常相似【可以递归定义】，并且可以在类型定义中使用 (意思是，可以和相同 签名的 class 类型匹配 【下面就有讲 unrelated_class】)。

此外，可以在没有类的情况下创建对象。它们被称为 【直接对象】 

*)


(* 
    
    直接定义 object， 语法等同 class 的 = 号后面的定义

    val obj : < set : int -> int -> unit > = <obj>    


    该类型仅由其公共方法定义。值不可见，私有方法也不可见（未显示）。与记录不同，这种类型不需要  显式预定义。  【查看  object  和 record 区别】


    ********************************************************************
    注意: 具有满足这个定义的方法 的 class 被认为是 相同的 对象类型
    ********************************************************************
*)
let obj = 
  object (self)
    val mutable x = 0
    val mutable y = 0
    method set new_x new_y = (x <- new_x; y <- new_y)
  end;;


(* - : unit = () *)
obj#set 1 2;;


(* 
********************************************************************  
对比下这句话: 

具有满足这个定义的方法 的 class 被认为是 相同的 对象类型

class 类型不是 【数据类型】，称为类型。 object 类型是一种【数据类型】，就像记录类型或元组一样。
定义 class 时，同时定义了同名的 class 类型和 object 类型


首先，我们定义上面与obj无关的类 
********************************************************************
*)
(* 
    class unrelated_class : object method set : int -> int -> unit end   
*)
class unrelated_class =
    object
      (* 定义一个显示x，y的方法集 *)
      method set x y = Printf.printf "(%d, %d)\n" x y
    end;;



(* 
    由于对象类型匹配，它们 【可以】被放在同一个列表中
    val obj2 : unrelated_class = <obj>
*)
let obj2 = new unrelated_class;;


(* 
      - : unrelated_class list = [<obj>; <obj>]

      ********************************************************************
      直接定义的 obj  和 使用 class 定义的 obj2 由于类型一致:
      ********************************************************************

      ********************************************************************
      都具备 方法:  set : int -> int -> unit end   
      ********************************************************************

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
   等同  obj#set
    - : unit = ()
*)
(hoge true)#set 1 2;;

(* 
      等同 unrelated_class#set
      (1, 2)
      - : unit = ()
*)
(hoge false)#set 1 2;;


(* 
********************************************************************
********************************************************************
object  和 record 区别
********************************************************************
********************************************************************

我们可以这样做：
*)

type counter = <get : int; incr : unit>;;   (* object 类型定义    type counter = < get : int; incr : unit > *)
type counter_r = {get : unit -> int; incr : unit -> unit};;  (* record 类型定义     type counter_r = { get : unit -> int; incr : unit -> unit; } *)


let r =
  let n = ref 0 in
    {get = (fun () -> !n);
     incr = (fun () -> incr n)};;   (* 实例化一个 record; 像 object 一样工作的记录的实现       val r : counter_r = {get = <fun>; incr = <fun>} *)

(* 
object  和 record 都很相似，但每种解决方案都有自己的优点： 

1、 速度： record 中的字段访问稍快一些

2、 字段名称：当某些字段名称相同时，操作不同类型的 record 会很不方便 【需要用到  多态变体】，但对于 object 来说这不是问题

3、 子类型化：不可能将 record 类型强制为 字段较少 的类型。 但对于 object 来说是可能的，因此共享某些方法的不同类型的 object 可以混合在一个数据结构中，其中只有它们的公共方法可见

4、 类型定义：不需要预先定义 object 类型，因此减轻了模块之间的依赖约束  (record 类型需要预先定义)
*)




(* 
######################################################################################################################################################
 部分 类型
######################################################################################################################################################
*)


(* 
********************************************************************
********************************************************************  
******************************************************************** 
print_class1 是 print_class2 的部分类型 
********************************************************************
********************************************************************
********************************************************************

原因， print_class2  的所有方法集 包含 print_class1 的所有方法集
*)

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


(* 
********************************************************************   
由于对象类型不同，print_class 1 和 print_class 2 【不能】放在 同一个列表中 
********************************************************************
*)
(* 
    Error: This expression has type print_class2
           but an expression was expected of type print_class1
           The second object type has no method print_2   
*)
let obj_list = [new print_class1; new print_class2];;



(* 
********************************************************************
    通过指导（类型转换）把它们放在同一个列表中

    【子类 :> 父类】


    【注意】 父类 :> 子类 是不允许的



    A :> B ==> A 实例 转  B 实例           
********************************************************************    
*)
(* 
    val obj_list : print_class1 list = [<obj>; <obj>]   
*)
let obj_list = [new print_class1; (new print_class2 :> print_class1)];;


(* 
********************************************************************   
子类被转化为 父类后的 引用不可以继续调用 子类特有的方法  (因为被擦除了)
********************************************************************

    val obj1 : print_class1 = <obj>
    val obj2 : print_class1 = <obj>
*)

let [obj1; obj2] = obj_list;;


(* 1- : unit = () *)
obj1#print_1;; (* 可以调用 【父类方法】 *)


(* 
      Error: This expression has type print_class1
      It has no method print_2   
*)
obj2#print_2;; (* 不能调用 【子类方法】，   因为 obj2 此时是一个 父类类型，没有子类方法*)




(* 
********************************************************************   
定义接受多层对象类型的函数  (这个 不是很明确， 略过)
********************************************************************

    val print1 : < print_1 : 'a; .. > -> 'a = <fun>   

    以上 < print_1 : 'a; .. > -> 'a = 中的 【-> 'a】 部分 'a 是一个【类型变量】 < print_1 : 'a; .. > 的别名
*)

let print1 print_obj = print_obj#print_1;;  (* 声明一个 全局的 print1 函数 传入  x 对象， 该函数要求入参的 x 具备  x#print_1 的调用*)


(* 1- : unit = () *)
print1 obj1;;

(* 1- : unit = () *)
print1 obj2;;



(* 
######################################################################################################################################################
多态类（具备泛型的类）
######################################################################################################################################################
*)


(* 
    class 的类型: 

********************************************************************
    class ['a] stack :
      object
        val mutable list : 'a list
        method peek : 'a
        method pop : 'a
        method push : 'a -> unit
        method size : int
      end   
********************************************************************      
*)

class ['a] stack =

    object (self)
      val mutable list = ( [] : 'a list )  (* 没办法 有 list 只能声明   'a   泛型啦 *)

      method push x = list <- x :: list    (* 推入堆栈 *)

      method pop =                         (* 从堆栈中移除(pop) *)
        let result = List.hd list in
        list <- List.tl list;
        result

      method peek = List.hd list     (* 堆栈峰值 *)

      method size = List.length list (* 堆栈的大小 *)

    end;;




(* 
######################################################################################################################################################
抽象类）
######################################################################################################################################################
*)

(* 
    class 的类型: 

********************************************************************
class virtual widget1 :
  string -> object method get_name : string method virtual repaint : unit end
********************************************************************
*)

class virtual widget1 (name : string) =
  object (self)
    method get_name =
      name
    method virtual repaint : unit
  end;;

(* 
class virtual container :
  string ->
  object
    val mutable widgets : widget1 list
    method add : widget -> unit
    method get_name : string
    method get_widgets : widget1 list
    method repaint : unit
  end   
*)
class virtual container name =
  object (self)
    inherit widget1 name
    val mutable widgets = ([] : widget1 list)
    method add w =
      widgets <- w :: widgets
    method get_widgets =
      widgets
    method repaint =
      List.iter (fun w -> w#repaint) widgets
  end;;

type button_state = Released | Pressed;;

(* 
class button :
  ?callback:(unit -> unit) ->
  string ->
  object
    val mutable state : button_state
    val mutable widgets : widget list
    method add : widget -> unit
    method get_name : string
    method get_widgets : widget list
    method press : unit
    method release : unit
    method repaint : unit
  end   
*)
class button ?callback name =
  object (self)
    inherit container name as super
    val mutable state = Released
    method press =
      state <- Pressed;
      match callback with
      | None -> ()
      | Some f -> f ()
    method release =
      state <- Released
    method repaint =
      super#repaint;
      print_endline ("Button being repainted, state is " ^
                     (match state with
                      | Pressed -> "Pressed"
                      | Released -> "Released"))
  end;;


let b = new button ~callback:(fun () -> print_endline "Ouch!") "button";;   (* val b : button = <obj> *)

b#repaint;;   (* Button being repainted, state is Released *)



b#press;;  (* Ouch! *)


b#repaint;; (* Button being repainted, state is Pressed *)


(* 
class label :
  string ->
  string -> object method get_name : string method repaint : unit end   
*)
class label name text =
  object (self)
    inherit widget1 name
    method repaint =
      print_endline ("Label: " ^ text)
  end;;

let l = new label "label" "Press me!";;   (* val l : label = <obj> *)
  
b#add l;;


(* 
Label: Press me!
  Button being repainted, state is Released   
*)
b#repaint;;    
  

let b = new button "button";;    (* val b : button = <obj> *)

let l = new label "label" "Press me!";;   (* val l : label = <obj> *)


let wl = ([] : widget1 list);;    (* 声明一个 父类类型的 list      val wl : widget list = [] *)


(* 
将 子类 转成 父类，再加入 list 中   
*)
let wl = (b :> widget1) :: wl;;    (* val wl : widget1 list = [<obj>] *)
let wl = (l :> widget1) :: wl;;    (* val wl : widget1 list = [<obj>; <obj>] *)
