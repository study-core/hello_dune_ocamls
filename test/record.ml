(* 
    type account = { name : string; mutable amount : int; }
*)
type account = {name:string;mutable amount:int};;

(* 
    val ac : account = {name = "bob"; amount = 1000}   
*)
let ac = {name = "bob"; amount = 1000};;

(* 
    - : unit = ()   
*)
ac.amount <- 999;;

(* 
    - : account = {name = "bob"; amount = 999}   
*)
ac;;

(* 
    不可改变
    Error: The record field name is not mutable
*)
let () = ac.name <- "Hoge";;

(* 
    这样是可以的
    - : unit = ()
*)
ac.name.[0] <- 'B';;

(* 
    - : account = {name = "Bob"; amount = 999}
*)
ac;;
