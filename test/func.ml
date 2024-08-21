(* 
######################################################################################################################################################
函数
######################################################################################################################################################
*)




(* 
相互递归   
*)

(* 
val even : int -> bool = <fun>
val odd : int -> bool = <fun> 
*)
let rec even n =
  match n with
  | 0 -> true
  | x -> odd (x-1)
and odd n =                (* 妈的， odd 这个不需要 rec ？？？ *)
  match n with
  | 0 -> false
  | x -> even (x-1);;


(* 
********************************************************************
********************************************************************
********************************************************************
********************************************************************
********************************************************************
********************************************************************
柯里化
********************************************************************
********************************************************************
********************************************************************
********************************************************************
********************************************************************
********************************************************************    

说白了就是部分函数，就是当传参不完整时返回的一个由剩余参数组成的新函数   
*)

let concat_curry s1 = fun s2 -> s1 ^ s2 ^ s1;;     (* val concat_curry : string -> string -> string = <fun> *)

concat_curry "a";;  (* 部分適用, 返回新函数： - : string -> string = <fun>  *)

(concat_curry "a") "b";; (* 完整的函数调用：- : string = "aba" *)


(* 
上述 柯里化 可以展开讲：

******************************************************************** 
******************************************************************** 
******************************************************************** 

let concat_curry s1 s2 = s1 ^ s2 ^ s1;; 

和

let concat_curry s1 = fun s2 -> s1 ^ s2 ^ s1;;

等价

********************************************************************
********************************************************************
********************************************************************

所以，let fuga x y z = x + y + z;;  可以写成：

let fuga x = fun y -> fun z -> x + y + z;;

所以，函数调用可以为：  f x y z => (((f x) y) z)


`let f 参数 = 表达式 `

是 

`let f = fun 参数 -> 表达式 `

的语法糖

******************************************************************** 
******************************************************************** 
******************************************************************** 
【注意】

函数是【左结合】

f x y z 即为  (((f x) y) z)

函数的构造函数是【右结合】

int - > int - > int - > int = <fun>  即为 int - >（int - >（int - > int））= <fun>

******************************************************************** 
******************************************************************** 
******************************************************************** 



*)

(* 将 运算符 放置中括号 () 中，可以得到新的函数 *)

(+);;  (* - : int -> int -> int = <fun> *)

(+) 1 2;;  (* - : int = 3 *)



(* 
   

let begin_page cgi title =
  let out = cgi # output # output_string in
  out "<html>\n";
  out "<head>\n";
  out ("<title>" ^ text title ^ "</title>\n");
  out ("<style type=\"text/css\">\n");
  out "body { background: white; color: black; }\n";
  out "</style>\n";
  out "</head>\n";
  out "<body>\n";
  out ("<h1>" ^ text title ^ "</h1>\n")



  其中 cgi # output # output_string "string" 是一个方法调用，类似于Java中的 cgi.output().output_string ("string")

  则 out 是 柯里化函数

  let out = ... 是该方法调用的部分函数应用程序（部分，因为尚未应用字符串参数）。因此， out 是一个函数，它接受一个字符串参数


  这里为 out  即是 cgi # output # output_string 的别名， 而完整的使用应为：


  cgi # output # output_string  "字符串"  也就是    out  "字符串"

*)


let  f1 x  =  x +1

let mf1 x y z = x + y + z

(* 
######################################################################################################################################################
fuction  关键字    let  f  = function x -> x +1      【 function 只接受一个 参数 】 故多参数的要写 多个 function 去 【右结合】
######################################################################################################################################################
*)
let  f2  = function x -> x +1;;

let mf2 = function x -> (function y -> (function z -> x + y + z));;  (* 类型为： val mf2 : int -> int -> int -> int 可应用于 偏函数 *)

let mf2_tuple = function (x, y, z) -> x + y + z;;  (* 类型为 val mf2_tuple : int*int*int -> int 不可应用于 偏函数*)

(* 
######################################################################################################################################################
fun  关键字   为了规避 多参数时 function 的繁琐写法，而有了  fun
######################################################################################################################################################
*)
let f3 = fun x -> x + 1;;

let mf3 = fun x y z -> x + y + z;;


(* 
********************************************************************
function  和  fun  的比较 1、 和 2、
********************************************************************
*)

(*
********************************   
1、 fun 可以由多个参数 
********************************
*)
let mm = fun x y z -> x + y + z;;

(* 
let mm = function x y z -> x + y + z;; 

Error: syntax error
*)


(* 
********************************   
2、 function 可以做模式匹配 
********************************
*)

let p = function true -> 1 | false -> 0;; 

(* 
let p = fun true -> 1 | false -> 0;;     

Error: syntax error
*)







(* 

函数不可以判断是否相等    (指 函数， 不限定 function 或 fun 关键字哈~)


(fun x -> x) = (fun x -> x)

Exception: Invalid_argument "equal: functional value".
*)




(* 自定义 函数别名 *)

let ( .%[]<- ) = Bytes.set;;



let str = "kally";;

(Bytes.of_string str).%[4] <- 'a';;   (* 等价于    Bytes.set (Bytes.of_string  str) 4 'a';;     *)