

(* 
  抛出异常   
  Exception: Not_found
*)
raise Not_found;;

(* 
    Exception: Sys_error ": No such file or directory"
*)
raise (Sys_error ": No such file or directory");;

(* 
    Exception: Sys_error ": ?\136\145?\154?\138\155?\135??\130常?\129"
*)
raise (Sys_error ": 我会抛出异常！");;

(* 
  定义可抛出异常的 递归函数
  val fact : int -> int = <fun>   
*)
let rec fact n =
  if n < 0 then raise (Invalid_argument ": negative argument")
  else if n = 0 then 1 else n * fact (n-1);;
(* 
   - : int = 120
*)
fact 5;;

(* 
   Exception: Invalid_argument ": negative argument"
*)
fact (-1);;


(* 
    捕获异常
    - : string = "not found !"   
*)
try raise Not_found with
  | Not_found -> "not found !"
  | _ -> "unknown !";;


(* 
    前面定义的 fact 函数例子
    - : int = 0 
*)
try fact (-1) with
  | Invalid_argument _ -> 0
  | _ -> 9999;;



(* 
    确认异常的变体类型
    - : exn = Not_found
*)
Not_found;;

(* 
    - : exn -> 'a = <fun>
*)
raise;;
