(* 动物类的接口声明 *)

class animal : string -> int ->
    object
      (* 构造函数参数：名字, 年龄 *)
      method get_name : string
      method set_name : string -> unit
      method get_age : int
      method set_age : int -> unit
      method speak : string
      method move : string
      method get_info : string
    end
  
  class dog : string -> int -> string ->
    object
      inherit animal
      (* 构造函数参数：名字, 年龄, 品种 *)
      method get_breed : string
      method wag_tail : string
      method fetch : string -> string
    end
  
  class cat : string -> int -> string ->
    object
      inherit animal
      (* 构造函数参数：名字, 年龄, 颜色 *)
      method get_color : string
      method purr : string
      method scratch : string
    end
  