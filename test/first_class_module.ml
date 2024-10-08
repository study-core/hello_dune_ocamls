(* 
######################################################################################################################################################

第一类 模块：

######################################################################################################################################################


OCaml 视为分为两部分：

      1. 涉及【值】和【类型】的         核心语言
      
      2. 涉及【模块】和【模块签名】的   模块语言



这些子语言是分层的：

  因为 模块 可以包含 类型 和 值

  但 普通值 不能包含 模块 或 模块类型

这意味着不能执行诸如： 

      定义 值 为 模块的变量 
      
      将 模块 作为 参数的函数 之类的操作





【解决】：   第一类模块
*)


(* 
   
第一类模块    是通过打包具有其满足的 签名 的模块  来创建的


这是使用 module 关键字完成的

*)

module type X_int = sig val x : int end;;

(* 
  定义一般模块

  module M = struct .. end                  (* module definition *)

  module M: sig .. end= struct .. end       (* module and signature *)



  而 函子 语法为：  module 函子Name (入参的模块变量名 : 入参的模块类型) = struct .. end   如： module MakeSet (Element : ELEMENT) = struct .. end 
*)
module Three : X_int = struct let x = 3 end;;   (* 一般模块 module and signature *) 

Three.x;;

(* 
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
*************************************************   
将 一般模块 转成 第一类模块
*************************************************


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


转换语法：


let  第一类模块名 = (module 要被转的一般模块 :  一般模块的类型)


let first-class-moduleName = (module moduleName : moduleType)

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
*)
let three = (module Three : X_int);;    (* val three : (module X_int) = <module> *)



(* 
*************************************************   
推断 和 匿名模块
*************************************************
*)
module Four = struct let x = 4 end;;   (* 通过类型推断，其类型为 module X_int *)  (* module Four : sig val x : int end *)

(* val numbers : (module X_int) list = [<module>; <module>] *)
let numbers = [ three; (module Four) ];;   (* 类型推断 Four 为  第一类模块 *)
(* 还可以写成 匿名模块 *)
let numbers = [three; (module struct let x = 4 end)];;



(* 
*************************************************   
拆开  第一类 模块
*************************************************



为了访问一流模块的内容，您需要将其解包到普通模块中。这可以使用 val 关键字来完成：


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


拆开语法：

  


  module 拆解出来的一般模块 = (val 第一类模块名  : 一般模块的类型)

  module moduleName = (val first-class-moduleName : moduleType)
    


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

*)

(* module New_three : X_int *)
module New_three = (val three : X_int);;    (* 【注意， 看这个啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊  !!!!!!!!!!!!!!!!!!!!!!1】 *)

(* 或者 module New_three = (val three);; *)


New_three.x;;


(* 

*****************************************************************************************************
*****************************************************************************************************
*****************************************************************************************************

【结论】：

    想要在 函数中使用  module 参数：

        
    
        则需要先将 module 转换成  第一类模块；

        并在要是用的地方 解开 第一类模块为 普通模块

*****************************************************************************************************
*****************************************************************************************************
*****************************************************************************************************

*)



(* 
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
*************************************************   
用于 操作 第一类 模块的 函数
*************************************************
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
*)

(* val to_int : (module X_int) -> int = <fun> *)
let to_int m =
  let module M = (val m : X_int) in
  M.x;;


(* val plus : (module X_int) -> (module X_int) -> (module X_int) = <fun> *)
let plus m1 m2 =(module struct let x = to_int m1 + to_int m2 end : X_int);; (* 函数 plus 返回一个新的 first-class module，其的 x 值为 first-class m1 的 x 加上 first-class m2 的 x *)


(* 使用模式匹配 *)
let to_int (module M : X_int) = M.x;;  (* 比上面的  to_int 定义 简洁， 明确了需要传入 first-class M 类型 *)  




let six = plus three three;;
to_int (List.fold_left  plus six [three;three]);;


(* 
*************************************************   
更丰富的例子
*************************************************
*)

(* module  type *)
module type Bumpable = sig
  type t
  val bump : t -> t
end;;

(* 没有指定 module 类型签名，也可以自动匹配到  module type Bumpable  ??? *)
module Int_bumper = struct
  type t = int
  let bump n = n + 1
end;;
(* 没有指定 module 类型签名，也可以自动匹配到  module type Bumpable  ??? *)
module Float_bumper = struct
  type t = float
  let bump n = n +. 1.
end;;

let int_bumper = (module Int_bumper : Bumpable);;   (* 这里又指定 module 签名类型 去拆解 module 了 ~~ *)

(* 注意：  第一类模块 不可以直接被使用， 因为它是 抽象的， type t 是抽象的，所以无法被推断，需要看下面的 例子做法 *)
let (module Bumper) = int_bumper in Bumper.bump 3;;
(* 
Error:  This expression has type Bumper.t but an expression was expected of type 'a
        The type constructor Bumper.t would escape its scope   
*)


(* 为了使 int_bumper 可用，我们需要公开类型 Bumpable.t 实际上等于 int 。下面我们将为 int_bumper 执行此操作，并为 float_bumper 提供相应的定义。 *)

(* 添加   【共享限制】  with type xxx *)

let int_bumper = (module Int_bumper : Bumpable with type t = int);;         (* 将 type t 明确为 int， 这时候 first-class module int_bumper 就不是抽象的了 *)

let float_bumper = (module Float_bumper : Bumpable with type t = float);;   (* 将 type t 明确为 float 这时候 first-class module float_bumper 就不是抽象的了 *)



let (module Bumper) = int_bumper in Bumper.bump 3;;           (* 嗯？ 不是用 module xx = (val int_bumper) 这样的语法？？ 可以直接用 let (module Bumper) 这样的语法来使用 x 值 ？？*)

let (module Bumper) = float_bumper in Bumper.bump 3.5;;


(* 
*************************************************   
还可以多态地使用这些一流的模块                           first-class module 的多态 
*************************************************

以下函数采用两个参数： Bumpable 模块 和与  模块的 t 类型相同类型的元素列表：   (即   下列的 a 【本地抽象类型】)
*)

(* val bump_list : (module Bumpable with type t = 'a) -> 'a list -> 'a list = <fun> *)
let bump_list  (type a)  (module Bumper : Bumpable with type t = a) (l: a list)  =  List.map Bumper.bump l;;

bump_list int_bumper [1;2;3];;

bump_list float_bumper [1.5;2.5;3.5];;

(* 
在此示例中， a 是 【本地抽象类型】。

对于任何函数，您都可以声明 (type a) 形式的 伪参数，它引入了名为 a 的新类型。





该类型的作用：                   类似于函数上下文中的抽象类型。




在上面的示例中，本地抽象类型用作共享约束的一部分，【该共享约束将类型 B.t 与传入的列表元素的类型联系起来】 即： B.t = a 和 a list


(可知  【本地抽象类型】 就是将 某些事务关联起来的)
*)


(* 

【本地抽象类型】 的关键属性之一是，它们在定义的函数中作为抽象类型进行处理，但从外部来看是多态的   

*)
let wrap_in_list (type a) (x:a) = [x];;  (* 可见 (type  a) 的写法就是其他语言中的 泛型参数   T 的意思 *)

wrap_in_list 18;;

wrap_in_list true;;

wrap_in_list "Gavin";;

(* 

************************************************************************************************************
************************************************************************************************************
************************************************************************************************************

但是， 如果我们尝试使用 【本地抽象类型】  a ，就好像它相当于某种具体类型，例如 int ，那么编译器会抱怨。

************************************************************************************************************
************************************************************************************************************
************************************************************************************************************

*)
let double_int (type a) (x:a) = x + x;;  (* Error: This expression has type a but an expression was expected of type int *)


















(* 
   

************************************************************************************************************
************************************************************************************************************
************************************************************************************************************
************************************************************************************************************
************************************************************************************************************
************************************************************************************************************

【本地抽象类型】 的一个常见用途是    -----------------------             【创建 可用于构造模块 的 新类型】

这是创建新的  第一类模块的示例: 


************************************************************************************************************
************************************************************************************************************
************************************************************************************************************
************************************************************************************************************
************************************************************************************************************
************************************************************************************************************


很棒的例子 ----
*)

module type Comparable = sig
  type t
  val compare : t -> t -> int
end;;

(* val create_comparable :  ('a -> 'a -> int) -> (module Comparable with type t = 'a) = <fun> *)
let create_comparable (type a) compare =   (* 使用 【本地抽象类型】*)
  (module struct
    type t = a
    let compare = compare
  end : Comparable with type t = a);;  (* 使用 【共享限制】 *)


create_comparable Int.compare;;     (* - : (module Comparable with type t = int) = <module> *)

create_comparable Float.compare;;   (* - : (module Comparable with type t = float) = <module> *)




(* 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   

示例： 查询处理框架

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*)
#require "ppx_jane";;


module type Query_handler = sig

  (** Configuration for a query handler *)
  type config

  val sexp_of_config : config -> Sexp.t
  val config_of_sexp : Sexp.t -> config

  (** The name of the query-handling service *)
  val name : string

  (** The state of the query handler *)
  type t

  (** Creates a new query handler from a config *)
  val create : config -> t

  (** Evaluate a given query, where both input and output are
      s-expressions *)
  val eval : t -> Sexp.t -> Sexp.t Or_error.t
end;;



(* 
   
我们可以再 module type 的 签名中 使用 ppx

(但 函子中却不行、  那 module 中行么 ??????)

*)
module type M = sig type t [@@deriving sexp] end;;
(* module type M = sig type t val t_of_sexp : Sexp.t -> t val sexp_of_t : t -> Sexp.t end *)





(* 
   
构造一个满足 Query_handler 接口的查询处理程序的示例。


我们将从一个生成唯一整数 ID 的处理程序开始，该处理程序通过保留一个内部计数器来工作，每次请求新值时该计数器都会增加。


在这种情况下，查询的输入只是简单的 s 表达式 () ，也称为 Sexp.unit 

*)
module Unique = struct
  type config = int [@@deriving sexp]
  type t = { mutable next_id: int }

  let name = "unique"
  let create start_at = { next_id = start_at }

  let eval t sexp =
    match Or_error.try_with (fun () -> unit_of_sexp sexp) with
    | Error _ as err -> err
    | Ok () ->
      let response = Ok (Int.sexp_of_t t.next_id) in
      t.next_id <- t.next_id + 1;
      response
end;;

(* val unique : Unique.t = {Unique.next_id = 0} *)
let unique = Unique.create 0;;

(* - : (Sexp.t, Error.t) result = Ok 0 *)
Unique.eval unique (Sexp.List []);;

(* - : (Sexp.t, Error.t) result = Ok 1 *)
Unique.eval unique (Sexp.List []);;


(* 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

另一个示例：执行目录列表的查询处理程序          

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*)

(* 这里，config 是解释相对路径的默认目录： *)
#require "core_unix.sys_unix";;

module List_dir = struct
  type config = string [@@deriving sexp]
  type t = { cwd: string }

  (** [is_abs p] Returns true if [p] is an absolute path  *)
  let is_abs p =
    String.length p > 0 && Char.(=) p.[0] '/'

  let name = "ls"
  let create cwd = { cwd }

  let eval t sexp =
    match Or_error.try_with (fun () -> string_of_sexp sexp) with
    | Error _ as err -> err
    | Ok dir ->
      let dir =
        if is_abs dir then dir
        else Core.Filename.concat t.cwd dir
      in
      Ok (Array.sexp_of_t String.sexp_of_t (Sys_unix.readdir dir))
end;;

(* val list_dir : List_dir.t = {List_dir.cwd = "/var"} *)
let list_dir = List_dir.create "/var";;

(* - : (Sexp.t, Error.t) result = Ok *)
(* (yp networkd install empty ma mail spool jabberd vm msgs audit root lib db
  at log folders netboot run rpc tmp backups agentx rwho) *)
List_dir.eval list_dir (sexp_of_string ".");;

(* - : (Sexp.t, Error.t) result = Ok (binding) *)
List_dir.eval list_dir (sexp_of_string "yp");;



(* 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   

分派到多个查询处理程序

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*)

(* 
果我们想将查询分派到任意处理程序集合，该怎么办？



理想情况下，我们只想将 【处理程序】 作为简单的数据结构（如列表）传递。

这对于单独的 【模块】 和 【函子】 来说是很尴尬的，但是对于 【第一类模块】 来说这是很自然的。

我们需要做的第一件事是创建一个签名，将 Query_handler 模块与实例化的查询处理程序相结合：   

*)

module type Query_handler_instance = sig
  module Query_handler : Query_handler
  val this : Query_handler.t
end;;  (* module type Query_handler_instance = sig module Query_handler : Query_handler val this : Query_handler.t end *)

(* 使用此签名，我们可以创建一个 第一类模块，其中包含查询的实例以及用于处理该查询的匹配操作 *)
let unique_instance =
  (module struct
    module Query_handler = Unique
    let this = Unique.create 0
end : Query_handler_instance);;  (* val unique_instance : (module Query_handler_instance) = <module> *)


(* 

以这种方式构造实例有点冗长，但我们可以编写一个函数来消除大部分样板文件。

请注意，我们再次使用 【本地抽象类型】

*)

let build_instance
      (type a)  (* 【本地抽象类型】 *)
      (module Q : Query_handler with type config = a)
      config
  =
  (module struct
    module Query_handler = Q
    let this = Q.create config
  end : Query_handler_instance);;   (* val build_instance : (module Query_handler with type config = 'a) -> 'a -> (module Query_handler_instance) = <fun> *)



let unique_instance = build_instance (module Unique) 0;;              (* val unique_instance : (module Query_handler_instance) = <module> *)

let list_dir_instance = build_instance (module List_dir)  "/var";;    (* val list_dir_instance : (module Query_handler_instance) = <module> *)

(* 
val build_dispatch_table :
  (module Query_handler_instance) list ->
  (string, (module Query_handler_instance)) Hashtbl.Poly.t = <fun>   
*)
let build_dispatch_table handlers =
  let table = Hashtbl.create (module String) in
  List.iter handlers
    ~f:(fun ((module I : Query_handler_instance) as instance) ->
      Hashtbl.set table ~key:I.Query_handler.name ~data:instance);
  table;;



(* 

val dispatch :
  (string, (module Query_handler_instance)) Hashtbl.Poly.t ->
  Sexp.t -> Sexp.t Or_error.t = <fun>

*)
let dispatch dispatch_table name_and_query =
  match name_and_query with
  | Sexp.List [Sexp.Atom name; query] ->
    begin match Hashtbl.find dispatch_table name with
    | None ->
      Or_error.error "Could not find matching handler"
        name String.sexp_of_t
    | Some (module I : Query_handler_instance) ->
      I.Query_handler.eval I.this query
    end
  | _ ->
    Or_error.error_string "malformed query";;

(* 

val cli : (string, (module Query_handler_instance)) Hashtbl.Poly.t -> unit = <fun>

*)
open Stdio;;
let rec cli dispatch_table =
  printf ">>> %!";
  let result =
    match In_channel.(input_line stdin) with
    | None -> `Stop
    | Some line ->
      match Or_error.try_with (fun () ->
        Core.Sexp.of_string line)
      with
      | Error e -> `Continue (Error.to_string_hum e)
      | Ok (Sexp.Atom "quit") -> `Stop
      | Ok query ->
        begin match dispatch dispatch_table query with
        | Error e -> `Continue (Error.to_string_hum e)
        | Ok s    -> `Continue (Sexp.to_string_hum s)
        end;
  in
  match result with
  | `Stop -> ()
  | `Continue msg ->
    printf "%s\n%!" msg;
    cli dispatch_table;;


(* 启动 *)
let () =  cli (build_dispatch_table [unique_instance; list_dir_instance])