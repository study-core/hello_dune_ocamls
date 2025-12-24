(** %%% 扩展示例 - 文件级别的扩展点 *)

(** 这个文件展示了 %%% 扩展的实际语法使用 *)

(** ===============================================
    以下是 %%% 扩展的实际使用示例代码：
    ===============================================
*)

[%%%module_wrapper {
  (** 这里是使用 %%%module_wrapper 扩展包装的实际代码 *)

  (** 类型定义 *)
  type person = {
    name : string;
    age : int;
    email : string;
  }

  (** 函数定义 *)
  let create_person name age email = {
    name = name;
    age = age;
    email = email;
  }

  let greet_person p =
    Printf.printf "Hello, %s! You are %d years old.\n" p.name p.age

  let get_person_info p =
    Printf.sprintf "%s (%d) - %s" p.name p.age p.email

  (** 主程序 *)
  let main () =
    let alice = create_person "Alice" 30 "alice@example.com" in
    let bob = create_person "Bob" 25 "bob@example.com" in

    greet_person alice;
    greet_person bob;

    print_endline (get_person_info alice);
    print_endline (get_person_info bob);

    print_endline "%%% 扩展示例运行完成！"

  (** 程序入口点 *)
  let () = main ()
}]

(** ===============================================
    注意：上面的 [%%%module_wrapper {...}] 语法是概念展示。
    在真正的 %%% 扩展实现中，这段代码会被转换为：

    module WrappedModule = struct
      type person = { name : string; age : int; email : string; }
      let create_person name age email = { name; age; email; }
      let greet_person p = Printf.printf "Hello, %s! You are %d years old.\n" p.name p.age
      let get_person_info p = Printf.sprintf "%s (%d) - %s" p.name p.age p.email
      let main () = (* ... 实际代码 ... *)
      let () = main ()
    end

    open WrappedModule

    ===============================================
*)

(** 为了让这个文件能够运行，这里提供等效的手动实现：*)
module ManualWrappedModule = struct
  type person = {
    name : string;
    age : int;
    email : string;
  }

  let create_person name age email = {
    name = name;
    age = age;
    email = email;
  }

  let greet_person p =
    Printf.printf "Hello, %s! You are %d years old.\n" p.name p.age

  let get_person_info p =
    Printf.sprintf "%s (%d) - %s" p.name p.age p.email

  let main () =
    let alice = create_person "Alice" 30 "alice@example.com" in
    let bob = create_person "Bob" 25 "bob@example.com" in

    greet_person alice;
    greet_person bob;

    print_endline (get_person_info alice);
    print_endline (get_person_info bob);

    print_endline "手动包装实现运行完成！"

  let () = main ()
end

(** 打开模块以便使用其中的定义 *)
open ManualWrappedModule
