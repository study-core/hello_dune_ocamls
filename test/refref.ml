(* 
    创建引用 r1 和 r2
    val r1 : int ref = {contents = 5}
    val r2 : int ref = {contents = 2}
*)
let r1 = ref 5 and r2 = ref 2;;

(* 
    引用的引用创建 rr1 和 rr2
    val rr1 : int ref ref = {contents = {contents = 5}}
    val rr2 : int ref ref = {contents = {contents = 2}}
*)
let rr1 = ref r1 and rr2 = ref r2;;


(* 
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
    引用操作 将 2 赋值给 r1
    ∵ !rr2 => r2  ∴ !(!rr2) => !r2 => 2
---------------------------------------------------------------------------------------------------- 
----------------------------------------------------------------------------------------------------   
*)
let () = !rr1 := !(!rr2);;  (* 竟然可以这样写等式 ................................................... *)
(* 
  - : int * int = (2, 2)
*)
(!r1, !r2);;

let () = print_string ((string_of_int !r1) ^ (string_of_int !r2) ^ "\n");;



(* 
   
OCaml 中的程序没有唯一的 main 函数。当评估 OCaml 程序时。
我们可以以 let () = 开头的声明扮演 main 函数的角色，启动处理。

*)