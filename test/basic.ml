(* 
  开始入门
*)


(* 
  内置基础类型：6 种
  int, float, char, string, and bool, unit
  
  
数据类型	  例子	         解释

int	        1	            有符号整数。在32位系统中长度为31位；在64位系统中长度为63位。
float	      1.	          浮点数。IEEE定义的双精度浮点数，等同于C语言的double。
bool	    true	
char	    'x'	            8 位的字符 (单引号)
string	 "hello"	        (双引号)   "string".[0];;    为 'h' /       let twice s = s ^ s;; 字符串拼接
unit	      ()	          ()是unit类型的唯一的值

*)

(* 类型： -:int *)
32  

(* val x : int = 42 *)
let x = 42;;



(* 
X 类型转换为 Y 类型的函数的命名规则为 Y_of_X   
*)
(* 
  - : int = 123   
*)
int_of_string "123";;

(* 
  val a : int = 1
  val b : int = 2    
*)
let a = 1 and b = 2;;


(* 元组 *)

(* - : int * int = (1, 2) *)
(1, 2);;

(* 
  - : char * int * string * float = ('a', 1, "str", 4.3)   
*)
('a', 1, "str", 4.3);;

(* 
  - : (int * int) * (char * string) = ((1, 2), ('a', "str"))   
*)
((1, 2), ('a', "str"));;
