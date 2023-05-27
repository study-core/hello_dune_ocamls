(* 
  ##########################################################
  ######################## 多态变体 ########################
  ##########################################################

    一种机制，可以为多种变体类型使用通用的构造函数  
    新的  函子 
*)
(* 
    消除 "构造函数 <=> 变体" 的限制   
*)

(* 
    缘由：
    type v1 = A | B of int | C of string * int

    type v2 = A | B of int

    则，

    使用 A  => v2 类型
    使用 B  => v2 类型
    使用 C  => v1 类型
    使用 D  => error

    而 【多态变体】可以使用 【单个构造子】，代替所有 定义的 构造子
    
    在两个不同变体类型之间共享标签，而 多态变体 正好可以以一种自然的方式做到这一点
*)




(* - : [> `Hoge ] = `Hoge *)
`Hoge;;

(* - : [> `Hoge of int ] = `Hoge 2 *)
`Hoge 2;;

(* - : [> `Hoge of [> `Fuga ] ] = `Hoge `Fuga *)
`Hoge `Fuga;;


(* 
      val f : bool -> [> `Fuga | `Hoge ] = <fun>   
*)
let f b = if b then `Hoge else `Fuga;;


(* 
      val hoge : [< `Fuga | `Hoge | `Piyo ] -> string = <fun>   
*)
let hoge = function
  | `Hoge -> "hoge"
  | `Fuga -> "fuga"
  | `Piyo -> "piyo";;


(* ----------------------------------------------------------------------------------------- *)
(* --------------------------------------- [>] 泛型限定 ------------------------------------ *)

(* > 当作  "这些或更多的标签" *)


(* 
 * 可以接受任何东西的多相变体列表
 类似，泛型限定

 a 为 `Int of string和 `Float of float的变体类型，但还可以包含更多的类型标签
 val a : [> `Fuga | `Piyo ] list = [`Fuga; `Piyo]
*)
let  a : [>] list = [`Fuga; `Piyo];;

(* 
  - : [> `Asdf | `Fuga | `Piyo ] list = [`Fuga; `Piyo; `Asdf]   
*)
a @ [`Asdf];;


(* ----------------------------------------------------------------------------------------- *)
(* --------------------------------------- [<] 泛型限定 ------------------------------------ *)


(* < 当作  "这些或更少的标签" *)


(* `Hoge,`within Fuga *)
(* 
  < 是 表示 f 无法处理含有 `Fuga 或 `Hoge  【以外】标签的值

  只能处理 `Fuga 或 `Hoge 类型

  val f : [< `Fuga | `Hoge ] -> string = <fun>   
*)
let f = function
  | `Hoge -> "hoge"
  | `Fuga -> "fuga";;


(* `Hoge, type within Fuga *)
(* type type_A = [ `Fuga | `Hoge ] *)
type type_A = [`Hoge | `Fuga];;

(* val a : type_A = `Hoge *)
let a : type_A = `Hoge;;

(* - : string = "hoge" *)
f a;;


(* `Hoge,`Fuga or more types *)
(* type type_B = [ `Fuga | `Hoge | `Piyo ] *)
type type_B = [`Hoge | `Fuga | `Piyo];;


(* `I'm Hoge type_B is `Hoge, `Fuga or more types *)
(* val b : type_B = `Hoge *)
let b : type_B = `Hoge;;

(* 
  Error: This expression has type type_B but an expression was expected of type
         [< `Fuga | `Hoge ]
         The second variant type does not allow tag(s) `Piyo   
*)
f b;; (* type error　*)


(* 
  我们可以把这些 < 和 > 标记看作已有标签的上下边界。如果标签集即是上边界又是下边界，我们就得到了一个确切的多态变体类型，什么标记都没有  
*)





(* ----------------------------------------------------------------------------------------- *)
(* --------------------------------------- 多态变体应用 ------------------------------------ *)

(* 
  常规 变体 做法   
*)
type basic_color =
   | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White ;;

let basic_color_to_int = function
   | Black -> 0 | Red     -> 1 | Green -> 2 | Yellow -> 3
   | Blue  -> 4 | Magenta -> 5 | Cyan  -> 6 | White  -> 7 ;;   

type weight = Regular | Bold ;;  

type color =
  | Basic of basic_color * weight (* basic colors, regular and bold *)
  | RGB   of int * int * int       (* 6x6x6 color cube *)
  | Gray  of int    ;;               (* 24 grayscale levels *)

let color_to_int = function
  | Basic basic_color -> basic_color_to_int basic_color
  | Bold  basic_color -> 8 + basic_color_to_int basic_color
  | RGB (r,g,b) -> 16 + b + g * 6 + r * 36
  | Gray i -> 232 + i ;;  


type extended_color =
    | Basic of basic_color * weight  (* basic colors, regular and bold *)
    | RGB   of int * int * int       (* 6x6x6 color space *)
    | Gray  of int                   (* 24 grayscale levels *)
    | RGBA  of int * int * int * int ;; (* 6x6x6x6 color space *)

(* 
  编译器识别不出来 Basic 等是属于 color 还是 extended_color 的， 因为同名了
  Error: This expression has type `extended_color` but an expression was expected of type `color`
*)
let extended_color_to_int = function
    | RGBA (r,g,b,a) -> 256 + a + b * 6 + g * 36 + r * 216
    | (Basic _ | RGB _ | Gray _) as color -> color_to_int color ;;   


(* 
  多态 变体 做法 
  
  可以解决上述问题
*)


type weight = `Regular | `Bold ;; 

type basic_color =
  [ `Black   | `Blue | `Cyan  | `Green
  | `Magenta | `Red  | `White | `Yellow ]

type color =
  [ `Basic of basic_color * [ `Bold | `Regular ]
  | `Gray of int
  | `RGB  of int * int * int ]


let basic_color_to_int = function
    | `Black -> 0 | `Red     -> 1 | `Green -> 2 | `Yellow -> 3
    | `Blue  -> 4 | `Magenta -> 5 | `Cyan  -> 6 | `White  -> 7 ;;


let color_to_int = function
    | `Basic (basic_color,weight) ->
      let base = match weight with `Bold -> 8 | `Regular -> 0 in
      base + basic_color_to_int basic_color
    | `RGB (r,g,b) -> 16 + b + g * 6 + r * 36
    | `Gray i -> 232 + i ;;    


(* 
      extended_color_to_int 要以窄化的类型（即更少的标签）调用color_to_int

      正常来讲，这种窄化可以使用模式匹配来完成
      
      下面的代码中，color变量只包含 `Basic、 `RGB和 `Gray标签，而不包含 `RGBA标签
*)
let extended_color_to_int = function
    | `RGBA (r,g,b,a) -> 256 + a + b * 6 + g * 36 + r * 216
    | (`Basic _ | `RGB _ | `Gray _) as color -> color_to_int color  ;;  


(* 上述代码最终修改 *)

(* mli 文件 *)
open Core.Std

type basic_color =
  [ `Black   | `Blue | `Cyan  | `Green
  | `Magenta | `Red  | `White | `Yellow ]

type color =
  [ `Basic of basic_color * [ `Bold | `Regular ]
  | `Gray of int
  | `RGB  of int * int * int ]

type extended_color =
  [ color
  | `RGBA of int * int * int * int ]

val color_to_int          : color -> int
val extended_color_to_int : extended_color -> int

(* OCaml ∗ variants-termcol/terminal_color.mli ∗ all code *)


(* ml 文件 *)
open Core.Std

type basic_color =
  [ `Black   | `Blue | `Cyan  | `Green
  | `Magenta | `Red  | `White | `Yellow ]

type color =
  [ `Basic of basic_color * [ `Bold | `Regular ]
  | `Gray of int
  | `RGB  of int * int * int ]

type extended_color =
  [ color
  | `RGBA of int * int * int * int ]

let basic_color_to_int = function
  | `Black -> 0 | `Red     -> 1 | `Green -> 2 | `Yellow -> 3
  | `Blue  -> 4 | `Magenta -> 5 | `Cyan  -> 6 | `White  -> 7

let color_to_int = function
  | `Basic (basic_color,weight) ->
    let base = match weight with `Bold -> 8 | `Regular -> 0 in
    base + basic_color_to_int basic_color
  | `RGB (r,g,b) -> 16 + b + g * 6 + r * 36
  | `Gray i -> 232 + i

let extended_color_to_int : extended_color -> int = function
  | `RGBA (r,g,b,a) -> 256 + a + b * 6 + g * 36 + r * 216
  | (`Basic _ | `RGB _ | `Gray _) as color -> color_to_int color (* 此处的 color 只是名字叫做 color 的变量，可以改成 其他的 如 x *)

(* 
    我们可以显式地使用类型名作为模式匹配的一部分，加一个#前缀

    当你想要窄化一个定义  很长的类型时，这就有用了，你绝不想在匹配中啰唆地显式重写这些标签

    使用 "#" 改进改进为
*)

let extended_color_to_int : extended_color -> int = function
  | `RGBA (r,g,b,a) -> 256 + a + b * 6 + g * 36 + r * 216
  | #color as color -> color_to_int color (* 此处的 color 只是名字叫做 color 的变量，可以改成 其他的 如 x ; 而 #color 的 color 是 color类型名称 *)

(* OCaml ∗ variants-termcol/terminal_color.ml ∗ all code *)

(* 
      ###################################################################
      ###################################################################
      ######### 能用 常规变体就用常规变体，不要轻易用 多态变体  #########
      ###################################################################
      ###################################################################
*)