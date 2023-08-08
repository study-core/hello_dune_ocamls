
(* 
######################################################################################################################################################
if 语句  
######################################################################################################################################################   
*)

(* 
   
if boolean-condition then expression
  
if boolean-condition then expression else other-expression

*)

(* 
用 begin ... end   
*)

(* 

if GtkBase.Object.is_a obj cls then
  fun _ -> f obj
else begin
  eprintf "Glade-warning: %s expects a %s argument.\n" name cls;
  raise Not_found
end

等价于

if GtkBase.Object.is_a obj cls then
  fun _ -> f obj
else (
  eprintf "Glade-warning: %s expects a %s argument.\n" name cls;
  raise Not_found
)

*)



(* 
######################################################################################################################################################
for / while 语句
######################################################################################################################################################
*)

(* 

for variable = start_value to end_value do
  expression
done
  
for variable = start_value downto end_value do
  expression
done


while boolean-condition do
  expression
done

*)

(* 
   
OCaml 不支持【for循环】中诸如 break, continue 或 last 这些语句的流控制（你可以 在循环体里抛出一个异常再在外面接著，但这个风格看起来太糟糕）

和for循环同样，【while循环】也不支持循环流控制，当然你还是可以用异常，但这说明while循环 其实是相当受限制的

*)

(* 

**************
**************
死循环
**************
**************

let quit_loop = false in
while not quit_loop do
  print_string "Have you had enough yet? (y/n) ";
  let str = read_line () in
  if str.[0] = 'y' then
    (* how do I set quit_loop to true ?!? *)
done

(* quit_loop 不是一个真正的变量，let 绑定只是让 quit_loop 成为 false 的简写  *)


我们可以这样写：(使用 引用/解引用)


let quit_loop = ref false in    (* 引用 *)

while not !quit_loop do         (* 解引用  !是 OCaml 的解引用 *)

  print_string "Have you had enough yet? (y/n) ";
  let str = read_line () in
  if str.[0] = 'y' then
    quit_loop := true
done;;

*)