(* 
    val s : string = "life"   
*)
let s = "life";;

(* 
    - : unit = ()   
*)
s.[2] <- 'v';;   (* 该语法已从 OCaml 5.0 中完全删除。原因是 s.[i] <- c 是 String.set 的别名，String.set 也已被删除 *)


(* 
    - : string = "live"   
*)
s;;


(* String.set 弃用 *)
(* 
    val f2 : string = "hoge"   
    - : unit = ()
    - : string = "Hoge"
*)
let f2 = "hoge";;
Bytes.set (Bytes.of_string  f2) 0 'H';;

f2;;


(* 

字符串是不可变的，这意味着不可能更改字符串内的字符值

字符串是有限且固定大小的 char 值序列。字符串连接运算符符号为 ^ 。

*)

"hello" ^ " " ^ "world!";;


(* 
   可以使用以下语法对字符串字符进行索引访问：
*)
"buenos dias".[4];;