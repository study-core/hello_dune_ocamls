
(* 
   类型别名: (go 或者 rust 中的 newtype)
   type latitude_longitude = float * float 
*)
type latitude_longitude = float * float;;








(* val tuple_sum : int * int -> int = <fun> *)
let tuple_sum (x, y) = x + y;;

(* val f : int * int -> int = <fun> *)
let f ((x, y) as arg) = tuple_sum arg;;  (* 其中 arg 是函数 f 的 (x, y) 参数别名 *)






(* type dummy_record = { a : int; b : int; } *)
type dummy_record = {a: int; b: int};;

(* val record_sum : dummy_record -> int = <fun> *)
let record_sum ({a; b}: dummy_record) = a + b;;

(* val f : dummy_record -> int = <fun> *)
let f ({a;b} as arg) = record_sum arg;;  (* 其中 arg 是函数 f 的 {a; b} 参数别名 *)