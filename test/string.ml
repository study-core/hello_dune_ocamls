(* 
    val s : string = "life"   
*)
let s = "life";;

(* 
    - : unit = ()   
*)
s.[2] <- 'v';;


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
Bytes.set f2 0 'H';;
f2;;
