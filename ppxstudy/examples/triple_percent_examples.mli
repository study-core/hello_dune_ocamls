(** %%% 扩展节点实例 - 整个文件的扩展点
    详细演示 %%% 扩展的用法和原理

    %%% 扩展是最强大的 PPX 扩展，可以影响整个文件
*)

(** ==================== 什么是 %%% 扩展 ==================== *)

(** %%% 扩展的基本语法：
    [%%%extension_name file_content]

    其中：
    - %%% 表示这是文件级别的扩展
    - extension_name 是扩展的名字
    - file_content 是整个文件的结构

    %%% 扩展可以：
    - 重新组织整个文件
    - 添加文件级别的包装
    - 进行全局代码转换
    - 实现复杂的重构
*)

(** ==================== 常见的 %%% 扩展 ==================== *)

(** 1. [%%%module_wrapper] - 模块包装

    将整个文件包装在一个模块中
*)

(** 2. [%%%auto_include] - 自动包含

    自动添加需要的打开语句和包含
*)

(** 3. [%%%logging] - 日志注入

    为所有函数添加日志记录
*)

(** 4. [%%%profiling] - 性能分析

    为所有函数添加性能监控
*)

(** ==================== 实际示例 ==================== *)

(** %%% 扩展在 .mli 文件中的使用示例 *)

(** 在接口文件中使用 %%% 扩展来声明包装后的模块接口：*)

[%%%module_wrapper {
  (** 这里是 .mli 文件中使用 %%%module_wrapper 扩展的实际示例 *)

  (** 类型声明 - 会被包装在模块中 *)
  type person = {
    name : string;
    age : int;
    email : string;
  }

  (** 函数声明 - 会被包装在模块中 *)
  val create_person : string -> int -> string -> person

  val greet_person : person -> unit

  val get_person_info : person -> string

  val find_person_by_name : string -> person list -> person option

  (** 异常声明 *)
  exception Person_not_found of string

  (** 子模块声明 *)
  module Utils : sig
    val validate_email : string -> bool
    val format_age : int -> string
  end
}]

(** 如果 %%%module_wrapper 扩展可用，编译后会生成：
    module WrappedModule : sig
      type person = { name : string; age : int; email : string; }
      val create_person : string -> int -> string -> person
      val greet_person : person -> unit
      val get_person_info : person -> string
      val find_person_by_name : string -> person list -> person option
      exception Person_not_found of string
      module Utils : sig
        val validate_email : string -> bool
        val format_age : int -> string
      end
    end

    然后可以通过 open WrappedModule 来使用这些定义
*)

(** ==================== %%% 扩展的特点 ==================== *)

(** 1. 文件级别的作用域
    %%% 扩展影响整个文件的所有代码
*)

(** 2. 强大的转换能力
    可以重新组织、重命名、包装代码
*)

(** 3. 编译时的处理
    在语法分析之后、类型检查之前执行
*)

(** 4. 相对少见
    因为功能强大，使用时需要谨慎
*)

(** ==================== 使用场景 ==================== *)

(** 1. 遗留代码迁移
    将旧代码包装到新模块结构中
*)

(** 2. 框架集成
    自动添加框架所需的样板代码
*)

(** 3. 代码重构
    大规模的自动化代码转换
*)

(** 4. DSL 实现
    实现领域特定语言的转换
*)

(** ==================== 注意事项 ==================== *)

(** 1. 调试困难
    转换后的代码可能与原始代码差异很大
*)

(** 2. 性能影响
    文件级别的转换可能增加编译时间
*)

(** 3. 兼容性
    确保与其他 PPX 扩展的顺序正确
*)

(** 4. 测试重要性
    由于转换复杂，必须充分测试
*)

(** 这个接口文件定义了 %%% 扩展可能生成的类型和函数 *)
type transformation_result =
  | Success of string  (** 转换成功，返回结果 *)
  | Failure of string  (** 转换失败，返回错误信息 *)

val apply_transformation : string -> transformation_result
(** 应用文件级别的转换 *)

val validate_file : string -> bool
(** 验证文件是否适合转换 *)

val generate_wrapper : string -> string -> string
(** 生成包装代码 *)
