

let return x = Some x
  
(* 绑定中缀运算，将f应用于m *)
let (>>=) m f =
 match m with
 | Some x -> f x
 | None  -> None
(**
Map 中缀运算

本质上与bind相同，但内部函数会打开值。
 **)
let (>>|) m f = m >>= (fun x -> return (f x))

let add_one = ((+) 1)
  
let bind_even : int -> int option = fun x -> if x mod 2 = 0 then Some x else None
 

let example x = x >>| add_one >>= bind_even;;

let () = 
    let op1 = example (Some 23) in 
      match op1 with
      | Some x -> Format.printf "This is Some(%d) \n" x
      | None  -> Format.printf "This is None \n";;

      let op2 = example None in 
      match op2 with
      | Some x -> Format.printf "This is Some(%d) \n" x
      | None  -> Format.printf "This is None \n";;


