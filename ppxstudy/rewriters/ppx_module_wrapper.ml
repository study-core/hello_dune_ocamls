(** 自定义 PPX 重写器：%%%module_wrapper 扩展
    演示如何创建文件级别的 PPX 扩展

    这个扩展会将整个文件包装在一个模块中
*)

open Ppxlib

(** ==================== 扩展注册 ==================== *)

(** 注册 %%%module_wrapper 扩展
    语法：[%%%module_wrapper file_content]

    这个扩展会：
    1. 创建一个包装模块
    2. 将所有代码放入模块中
    3. 添加模块打开语句
*)

let module_wrapper_extension =
  Extension.declare
    "module_wrapper"                (* 扩展的名字 *)
    Extension.Context.structure_item (* 扩展的上下文：结构项（简化处理） *)
    Ast_pattern.(pstr __)          (* 匹配结构项列表 *)
    (fun ~loc ~path:_ structure_items ->
       (* 生成模块名 *)
       let module_name = "WrappedModule" in

       (* 创建模块结构 *)
       let module_expr = Ast_helper.Mod.structure structure_items in
       let module_binding = Ast_helper.Mb.mk
         (Ast_helper.Pat.var {txt = module_name; loc})
         module_expr
       in
       let module_decl = Ast_helper.Str.module_ module_binding in

       (* 创建打开语句 *)
       let open_stmt = Ast_helper.Str.open_ (Ast_helper.Opn.mk
         (Ast_helper.Mod.ident {txt = Longident.Lident module_name; loc})) in

       (* 返回新的结构：模块声明 + 打开语句 *)
       [module_decl; open_stmt]
    )

(** 注册重写器 *)
let () = Driver.register_transformation "module_wrapper" ~extensions:[module_wrapper_extension]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用（对应项目中的实际示例）：

    (* 在 .mli 文件中：*)
    [%%%module_wrapper {
      type person = { name : string; age : int; email : string; }
      val create_person : string -> int -> string -> person
      val greet_person : person -> unit
      val get_person_info : person -> string
      exception Person_not_found of string
    }]

    (* 在对应的 .ml 文件中：*)
    [%%%module_wrapper {
      type person = { name : string; age : int; email : string; }

      let create_person name age email = { name; age; email; }

      let greet_person p = Printf.printf "Hello, %s!\n" p.name

      let get_person_info p = Printf.sprintf "%s (%d) - %s" p.name p.age p.email

      exception Person_not_found of string

      let main () =
        let alice = create_person "Alice" 30 "alice@example.com" in
        greet_person alice;
        print_endline (get_person_info alice)

      let () = main ()
    }]

    (* 编译后会转换为：
       module WrappedModule = struct
         type person = { name : string; age : int; email : string; }
         let create_person name age email = { name; age; email; }
         let greet_person p = Printf.printf "Hello, %s!\n" p.name
         let get_person_info p = Printf.sprintf "%s (%d) - %s" p.name p.age p.email
         exception Person_not_found of string
         let main () = (* ... *)
         let () = main ()
       end

       open WrappedModule
    *)

    (* 也可以查看项目中的实际示例：
       - examples/triple_percent_examples.mli
       - examples/triple_percent_examples.ml
    *)

*)

(** ==================== 注意事项 ==================== *)

(** 1. 这个实现是简化的
    在实际的文件级别扩展中，应该使用 Extension.Context.whole_file

    2. 文件级别扩展很少见
    因为它们会影响整个文件的结构，需要谨慎使用

    3. 实际的文件级别扩展通常用于：
    - 代码重构和迁移
    - 框架集成
    - 大规模代码转换
*)

(** ==================== 扩展说明 ==================== *)

(** 这个 %%%module_wrapper 扩展演示了：

    1. 如何创建文件级别的转换
    2. 如何重新组织代码结构
    3. 如何创建模块和打开语句
    4. 如何同时保留和转换代码

    文件级别的扩展功能强大但复杂，使用时需要特别小心
*)
