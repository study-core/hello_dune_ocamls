(* 
    定义不需要有意义的参数的函数时用作参数
    val const : unit -> int = <fun>
*)
let const () = 777;;

(* 
    - : int = 777   
*)
const ();;


(* 
    () 将匹配模式，如果操作成功，将返回 unit 类型
    也就是说，如果匹配成功，则表示操作成功
    修改字符串 "Test" 下标 1 的字符为 C
    得到 "TCst"
*)
let () = Bytes.set (Bytes.of_string "Test") 1 'C';;