[];;  (* - : 'a list = [] *)

[1; 2; 3];; (* - : int list = [1; 2; 3] *)

[false; true; false];; (* - : bool list = [false; true; false] *)

[[1; 2]; [3; 4]; [5; 6]];;  (* - : int list list = [[1; 2]; [3; 4]; [5; 6]] *)




(* 
######################################################################################################################################################

@ 和 # 操作符

######################################################################################################################################################
*)


1 :: [2; 3];; (* - : int list = [1; 2; 3] *)

[1] @ [2; 3];;  (* - : int list = [1; 2; 3] *)

(* 
********************************************************************
自定义函数
********************************************************************   
*)

let rec total l =
  match l with
  | [] -> 0
  | h :: t -> h + total t;;   (* val total : int list -> int = <fun> *)

total [1; 3; 5; 3; 1];;  (* - : int = 13 *)



let rec length l =
  match l with
  | [] -> 0
  | _ :: t -> 1 + length t;;  (* val length : 'a list -> int = <fun> *)


let rec append a b =
  match a with
  | [] -> b
  | h :: t -> h :: append t b;;  (* val append : 'a list -> 'a list -> 'a list = <fun>   *)




(* 
######################################################################################################################################################

标准库

######################################################################################################################################################
*)

List.map (fun x -> x * 2) [1; 2; 3];;  (* - : int list = [2; 4; 6] *)


List.map2 ( + ) [1; 2; 3] [4; 5; 6];;  (* - : int list = [5; 7; 9] *)


(* 
frank
james
mary   
*)
List.iter print_endline ["frank"; "james"; "mary"];;

(* 
frank carter
james lee
mary jones   
*)
List.iter2
    (fun a b -> print_endline (a ^ " " ^ b))
    ["frank"; "james"; "mary"]
    ["carter"; "lee"; "jones"];;


List.mem "frank" ["james"; "frank"; "mary"];;  (* 类似 contains() 函数     - : bool = true   *)
     

(* open Printf
let a = [1;2;3;4;5]
let () = List.iter (printf "%d ") a *)

let allEven = not (List.mem false (List.map (fun x -> x mod 2 = 0) [2; 4; 6; 8]));;  (* 是否全部为 偶数；  val allEven : bool = true *)

let anyEven =  List.mem true (List.map (fun x -> x mod 2 = 0) [1; 2; 3]);;  (* 是否存在偶数；  val anyEven : bool = true *)

List.for_all (fun x -> x mod 2 = 0) [2; 4; 6; 8];;   (* - : bool = true  *)

List.exists (fun x -> x mod 2 = 0) [1; 2; 3];;  (* - : bool = true *)


List.find (fun x -> x mod 2 = 0) [1; 2; 3; 4; 5];;  (* 找到则返回第一个； - : int = 2 *)

List.find (fun x -> x mod 2 = 0) [1; 3; 5];;  (* 找不到则返回异常：  Exception: Not_found. *)

List.filter (fun x -> x mod 2 = 0) [1; 2; 3; 4; 5];;  (* - : int list = [2; 4] *)

List.partition (fun x -> x mod 2 = 0) [1; 2; 3; 4; 5];;  (* - : int list * int list = ([2; 4], [1; 3; 5])  *)
