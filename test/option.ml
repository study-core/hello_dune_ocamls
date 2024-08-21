(* 
option 类型也是多态类型。选项值可以存储任何类型的数据或表示不存在任何此类数据。选项值只能以两种不同的方式构造：当没有可用数据时为 None ，否则为 Some    
*)


(* - : 'a option = None *)
None;;

(* - : int option = Some 42 *)
Some 42;;


(* - : string option = Some "hello" *)
Some "hello";;


match Some 42 with None -> raise Exit | Some x -> x;;


(* 在 OCaml 的顶层 topup 中可以使用  #show xxx 查看 xxx 的定义 *)

(* type 'a option = None | Some of 'a *)
#show option;;

(* type 'a list = [] | (::) of 'a * 'a list *)
#show list;;

