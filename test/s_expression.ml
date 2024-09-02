(* 

【S-表达式】 是 OCaml 社区中流行的文本序列化格式.

就像 JSON 或 YAML 可用于在基于 Web 的上下文中的各个组件之间传递结构化数据一样, 
S 表达式通常在 OCaml 到 OCaml 上下文中扮演相同的角色. 

S-表达式格式不仅限于 OCaml, 而且相当古老, 它是为 Lisp 语言发明的.






【S 表达式】表示为用括号括起来的嵌套列表. 
(列表的每个元素可以是一个原子或另一个嵌套列表)

如: 


()
(a)
(a b)
(a b c)
(a (b 0) (c 1.2))

*)


#use "topfind";;
# require "sexplib";;
open Sexplib;;



(* - : Type.t = Sexplib.Sexp.Atom "1" *)
Sexp.Atom "1";;  (* 创建  (1) 的 s-表达式 *)


(* - : Type.t = Sexplib.Sexp.List [Sexplib.Sexp.Atom "1"; Sexplib.Sexp.Atom "2"] *)
Sexp.List [Atom "1"; Atom "2"];; (* 创建 (1, 2) 的 s-表达式 *)



Format.printf "%a\n" Sexp.pp Sexp.(List [List [Atom "1"; Atom "hello"]]);;  (* 格式化显示: ((1 hello)) *)


Sexp.save "my_sexp_file" Sexp.(List [List [Atom "1"; Atom "hello"]]);;   (* 将:  ((1 hello))  写到文件 my_sexp_file 中 *)










(* 

【s-表达式】的应用 (看下面这句话):


在以前(1995 年之前), 实际上只有一种这样的语言: 【s-表达式】.
然后 XML 出现, 它告诉我们不该做什么. 
从那时起, 我们有了许多新语言: YAML、JSON、INI、protobufs.

*)