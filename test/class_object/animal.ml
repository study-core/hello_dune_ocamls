(* 动物类的实现 *)

(* 父类：动物 *)
class animal (name_init : string) (age_init : int) =
  object  (* 这里不需要 (self)，因为父类中没有使用self引用 *)
    (* 实例变量 *)
    val mutable name = name_init
    val mutable age = age_init

    (* getter方法 *)
    method get_name = name
    method get_age = age

    (* setter方法 *)
    method set_name new_name = name <- new_name
    method set_age new_age = age <- new_age

    (* 基础方法 *)
    method speak = "我是一只动物"

    method move = "我在移动"

    (* 使用多个参数的方法 *)
    method get_info =
      Printf.sprintf "名字：%s，年龄：%d岁" name age
  end

(* 子类：狗 *)
class dog (name_init : string) (age_init : int) (breed_init : string) =
  object (self)
    (* 继承父类的所有成员，传递多个参数给父类 *)
    inherit animal name_init age_init as super_animal

    (* 子类特有的实例变量 *)
    val breed = breed_init

    (* 子类特有的getter方法 *)
    method get_breed = breed

    (* 重写父类的speak方法 *)
    method! speak =
      Printf.sprintf "汪汪！我叫%s，%s，我是一只%s" (self#get_name) (super_animal#speak) breed

    (* 重写父类的move方法 *)
    method! move =
      Printf.sprintf "%s，我在跑步" (super_animal#move)

    (* 重写父类的get_info方法，使用父类和子类的多个参数 *)
    method! get_info =
      Printf.sprintf "%s，品种：%s" (super_animal#get_info) breed

    (* 狗特有的方法 *)
    method wag_tail = "尾巴在摇晃"

    method fetch item =
      Printf.sprintf "%s（%d岁）去捡%s" (self#get_name) (self#get_age) item
  end

(* 子类：猫 *)
class cat (name_init : string) (age_init : int) (color_init : string) =
  object (self)
    (* 继承父类的所有成员，传递多个参数给父类 *)
    inherit animal name_init age_init as parent_animal

    (* 子类特有的实例变量 *)
    val color = color_init

    (* 子类特有的getter方法 *)
    method get_color = color

    (* 重写父类的speak方法，使用父类的多个参数 *)
    method! speak =
      Printf.sprintf "喵喵！我叫%s，%s，我是%s色的" (parent_animal#get_name) (parent_animal#speak) color

    (* 重写父类的move方法 *)
    method! move =
      Printf.sprintf "%s，我在优雅地走动" (parent_animal#move)

    (* 重写父类的get_info方法，使用父类和子类的多个参数 *)
    method! get_info =
      Printf.sprintf "%s，颜色：%s" (parent_animal#get_info) color

    (* 猫特有的方法 *)
    method purr = "呼噜呼噜~"

    method scratch =
      Printf.sprintf "我这只%d岁的%s猫在用爪子挠东西" (self#get_age) color
  end
