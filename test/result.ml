(* 
result 类型可用于表示函数的结果可以是成功或失败。构建结果值只有两种方法：使用具有预期含义的 Ok 或 Error

两个构造函数都可以保存任何类型的数据。 

result 类型是多态的，但它有两个类型参数：一个用于 Ok 值，另一个用于 Error 值   
*)


(* - : (int, 'a) result = Ok 42 *)
Ok 42;;

(* - : ('a, string) result = Error "Sorry" *)
Error "Sorry";;