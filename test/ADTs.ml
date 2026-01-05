(* 
######################################################################################################################################################
######################################################################################################################################################

抽象数据类型（Abstract Data Types, ADTs）是

变体（Variant Types）和

记录（Record Types）的统称


GADTs（广义代数数据类型）是 ADTs 的一个高级扩展  （它们允许您在定义变体类型的构造器时，指定更复杂的返回类型约束，从而实现常规 ADTs 无法实现的类型安全保证）

######################################################################################################################################################
######################################################################################################################################################

*)

(*
######################################################################################################################################################
######################################################################################################################################################

变体类型（Variant Types）、多态变体（Polymorphic Variants）和记录类型（Record Types）的使用场景详解

######################################################################################################################################################
######################################################################################################################################################
*)

(*
========================================================================================================================
1. 变体类型（Variant Types）- 求和类型
========================================================================================================================

变体类型用于表示"或"的关系，即数据可能是几种不同类型中的一种。

常见使用场景：
- 状态表示：如用户状态（登录/登出）、订单状态（待支付/已支付/已发货）
- 错误处理：Result 类型，`OK value | Error error_message`
- 枚举类型：如方向（North | South | East | West）
- 递归数据结构：树结构、二叉树、抽象语法树（AST）
- 消息类型：在并发编程中表示不同类型的消息
========================================================================================================================
*)

(* 变体类型 - "这个或那个" *)
type status = OK | Error of string | Loading

(* 状态表示示例 *)
type user_status = LoggedIn of string | LoggedOut

(* 订单状态示例 *)
type order_state = Pending | Paid | Shipped | Delivered

(* 递归数据结构示例：二叉树 *)
type 'a tree = Leaf | Node of 'a * 'a tree * 'a tree

(* 创建一个简单的树 *)
let my_tree = Node (1, Node (2, Leaf, Leaf), Node (3, Leaf, Leaf))

(*
========================================================================================================================
2. 多态变体（Polymorphic Variants）
========================================================================================================================

多态变体提供了更大的灵活性，不需要预先定义类型。

常见使用场景：
- 模块间通信：不同模块可以发送不同类型的消息，无需共享类型定义
- 可扩展的 API：允许第三方代码添加新的构造器
- 类型安全的配置：配置选项可以是不同类型的值
- 事件系统：GUI 事件或其他事件驱动编程
- 协议消息：网络协议中不同类型的消息
========================================================================================================================
*)

(* 多态变体 *)
type msg1 = [`Text of string | `Number of int]
type msg2 = [`Image of bytes | `Number of int]

(*
========================================================================================================================
3. 记录类型（Record Types）- 积类型
========================================================================================================================

记录类型用于将多个相关字段组合在一起，表示"这个和那个"的关系。

核心概念："这个和那个"（And）vs "这个或那个"（Or）
- 记录 = 同时拥有多个属性（And）：一个人既有名又有年龄
- 变体 = 可能是多种类型之一（Or）：一个值可能是整数或字符串

常见使用场景：
- 数据聚合：用户信息、产品信息、配置对象
- 函数参数：当函数需要多个相关参数时
- 数据库行：表示数据库表中的一行数据
- API 响应：HTTP API 返回的结构化数据
- 配置结构体：应用程序配置、系统设置
========================================================================================================================
*)

(* 记录类型 - "这个和那个" *)
type user = {name: string; email: string}

(* 字段相同但类型不同 *)
type person = {name: string; email: string}





(* 基本操作 *)
let create_user name email = {name; email}
let create_person name email = {name; email}

let print_user user = Printf.printf "用户: %s\n" user.name
let print_person person = Printf.printf "人员: %s\n" person.name

(* 演示 *)
let demo () =
  let user = create_user "张三" "zhangsan@example.com" in
  let person = create_person "李四" "lisi@example.com" in
  print_user user;
  print_person person;
  print_string "user 和 person 是不同类型！\n"

(* 总结：
   1. 变体表示"或"关系
   2. 记录表示"和"关系
   3. 结构相同的记录类型也是不同类型
*)
(* 这里的 msg 类型是 [< `Image of 'a | `Number of int | `Text of string ] *)
(* 该函数的签名为: [< `Image of 'a | `Number of int | `Text of string ] -> unit *)
let handle_msg msg =
  match msg with
  | `Text s -> print_string ("Text: " ^ s)
  | `Number n -> print_int n; print_newline ()
  | `Image b -> print_string "Image received\n"

(* 测试多态变体 *)
let test_msg1 = `Text "Hello"   (* 类型是 [> `Text of string] *)
let test_msg2 = `Number 42      (* 类型是 [> `Number of int] *)

(* 类型推断示例 *)
let example_number = `Number 2  (* 类型是 [> `Number of int] *)

(* 函数参数类型推断 *)
(* 函数签名为:  msg1 -> unit *)
let process_msg1 (msg : msg1) = ()  (* 只接受 msg1 类型 *)
(* 函数签名为:  msg2 -> unit *)
let process_msg2 (msg : msg2) = ()  (* 只接受 msg2 类型 *)

(* 测试类型推断 *)
(* let _ = process_msg1 (`Number 2)  (* 这会推断为 msg1 类型 *) *)
(* let _ = process_msg2 (`Number 2)  (* 这会推断为 msg2 类型 *) *)

(* 如果没有类型约束，编译器会选择最通用的类型 *)
(* 函数签名为:  [< `Image of 'a | `Number of int | `Text of string ] -> unit *)
let flexible_function msg = match msg with
  | `Number n -> Printf.printf "数字: %d\n" n
  | `Text s -> Printf.printf "文本: %s\n" s
  | `Image _ -> print_string "图片\n"



(* 用户信息记录 *)
type user = {
  id: int;
  name: string;
  email: string;
  created_at: float;
}

(* 人员信息记录 - 字段完全一样但类型不同 *)
type person = {
  id: int;
  name: string;
  email: string;
  created_at: float;
}

(* 应用程序配置记录 *)
type config = {
  host: string;
  port: int;
  debug: bool;
  timeout: float;
}

(* 创建示例数据 *)
let sample_user = {
  id = 1;
  name = "张三";
  email = "zhangsan@example.com";
  created_at = Unix.time ();
}

let sample_config = {
  host = "localhost";
  port = 8080;
  debug = true;
  timeout = 30.0;
}

(*
简单示例：记录表示"这个和那个"

一个人同时有：姓名 AND 年龄 AND 邮箱 → 用记录
一个配置同时有：主机 AND 端口 AND 调试 → 用记录

对比变体：HTTP响应可能是成功 OR 失败 OR 加载中 → 用变体
*)

(*
========================================================================================================================
记录类型的使用函数示例（简化版）
========================================================================================================================
*)

(* ===== 用户记录的基本操作 ===== *)

(* 简单的用户信息打印 *)
let print_user (user : user) : unit =
  Printf.printf "用户 - ID: %d, 姓名: %s, 邮箱: %s\n"
    user.id user.name user.email

(* 简单的人员信息打印 *)
let print_person (person : person) : unit =
  Printf.printf "人员 - ID: %d, 姓名: %s, 邮箱: %s\n"
    person.id person.name person.email

(* 更新用户名 *)
let update_user_name (user : user) (new_name : string) : user =
  { user with name = new_name }

(* 创建新用户（简化版）- 显式类型注解 *)
let create_user (name : string) (email : string) : user =
  {
    id = 1;  (* 固定ID用于示例 *)
    name = name;
    email = email;
    created_at = 0.0;  (* 简化时间戳 *)
  }

(* 创建新人员（简化版）- 显式类型注解 *)
let create_person (name : string) (email : string) : person =
  {
    id = 2;  (* 固定ID用于示例 *)
    name = name;
    email = email;
    created_at = 0.0;  (* 简化时间戳 *)
  }

(*
========================================================================================
导致类型推断问题的根本原因详解
========================================================================================

上面如果写成：

let create_user name email = { id = 1; name = name; email = email; created_at = 0.0 }
let create_person name email = { id = 2; name = name; email = email; created_at = 0.0 }

都会因为"类型统一"原则导致 create_user 返回 person 类型而不是 user 类型。

根本原因：
1. OCaml 使用的是"名义类型系统"，但记录类型的推断有特殊规则
2. 当记录结构完全相同时，编译器会进行"类型统一"
3. 统一时选择"最后定义"的类型（person 在 user 之后定义）
4. 这就是所谓的"记录类型歧义"问题

解决方案：使用显式类型注解来避免类型推断的歧义
========================================================================================
*)

(* ===== 配置记录的基本操作 ===== *)

(* 打印配置 *)
let print_config config =
  Printf.printf "主机: %s, 端口: %d, 调试: %b, 超时: %.1f\n"
    config.host config.port config.debug config.timeout;
  () (* 在 OCaml 中，函数如果没有显式的返回值，编译器会推断返回最后一条表达式的值, 所以这里必须通过添加明确的 () 返回 unit 类型值 *)

(* 更新端口 *)
let update_port config new_port =
  { config with port = new_port }

(* 启用调试模式 *)
let enable_debug config =
  { config with debug = true }





(* ===== 记录类型兼容性演示 ===== *)

(* 演示：结构相同的记录类型也是不同的类型 *)
let demo_type_compatibility () =
  let user = create_user "张三" "zhangsan@example.com" in
  let person = create_person "李四" "lisi@example.com" in

  (* 可以正常使用各自的类型 *)
  print_user user;
  print_person person;
  (* 以下代码如果取消注释会编译错误：
     因为 user 和 person 类型不同，即使字段完全一样
     print_person user;  (* 错误：user 不能当作 person 使用 *)
     print_user person;  (* 错误：person 不能当作 user 使用 *)
     let person_from_user = user;  (* 错误：类型不匹配 *)
  *)
  ()  (* 在 OCaml 中，函数如果没有显式的返回值，编译器会推断返回最后一条表达式的值, 所以这里必须通过添加明确的 () 返回 unit 类型值 *)


(* ===== 简单示例使用 ===== *)

(* 创建和使用用户 *)
let demo_user () =
  let user1 = create_user "张三" "zhangsan@example.com" in
  let user2 = update_user_name user1 "李四" in
  print_user user1;
  print_user user2;
  () (* 在 OCaml 中，函数如果没有显式的返回值，编译器会推断返回最后一条表达式的值, 所以这里必须通过添加明确的 () 返回 unit 类型值 *)

(* 创建和使用配置 *)
let demo_config () =
  let config1 = update_port sample_config 9000 in
  let config2 = enable_debug config1 in
  print_config sample_config;
  print_config config1;
  print_config config2;
  () (* 在 OCaml 中，函数如果没有显式的返回值，编译器会推断返回最后一条表达式的值, 所以这里必须通过添加明确的 () 返回 unit 类型值 *)

(*
========================================================================================================================
选择使用哪种类型的指导原则：
========================================================================================================================

1. "这个或那个"（Sum Type）→ 使用变体
   示例：HTTP状态 = OK(200) 或 NotFound(404) 或 Error(500)
   代码：type status = OK | NotFound | Error

2. 需要扩展性的"或"关系 → 使用多态变体
   示例：消息 = 文本 或 数字（可由不同模块扩展）
   代码：type msg = [`Text of string | `Number of int]

3. "这个和那个"（Product Type）→ 使用记录
   示例：人 = 姓名 AND 年龄 AND 邮箱（同时拥有）
   代码：type person = {name: string; age: int; email: string}

4. 需要命名参数时 → 使用记录
   示例：函数参数太多时，用记录打包
   代码：let create_user (config: user_config) = ...

========================================================================================================================
*)

(*
总结：ADTs 的核心概念

1. 变体类型（Variant）- 表示"这个或那个"：
   type status = OK | Error | Loading

2. 多态变体（Polymorphic Variant）- 可扩展的"或"关系：
   type msg = [`Text of string | `Number of int]

3. 记录类型（Record）- 表示"这个和那个"：
   type person = {name: string; age: int; email: string}

选择原则：
- 需要"或"关系时用变体
- 需要同时拥有多个属性时用记录
- 需要类型安全时用显式注解
*)
