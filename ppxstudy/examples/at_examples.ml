(** @ 扩展示例 - 模式级别的扩展点 *)

(** 状态：历史语法草稿。@ 不是“模式级扩展”标记，下列自定义记号不能由
    当前 rewriters 直接构建；准确信息见同目录 README.md。 *)

(** ===============================================
    @ 扩展语法示例（概念展示）
    ===============================================

    注意：以下示例中的 @ 扩展都是教学演示，
    需要对应的 PPX 重写器才能实际工作。

    只有 @bind 是真实存在的第三方扩展。
    ===============================================
*)

(** 🛠️ 自定义 @ 扩展示例（需要实现对应的重写器） *)

(** 正则表达式模式匹配扩展 (@regex) - 自定义 *)
let classify_string s =
  match s with
  | _ @regex "^\\d+$" -> "number"        (* 纯数字 *)
  | _ @regex "^[a-zA-Z]+$" -> "letters"  (* 纯字母 *)
  | _ @regex "^[a-zA-Z0-9]+$" -> "alphanumeric" (* 字母数字 *)
  | _ -> "other"

(** 展开后代码：
    let classify_string s =
      match s with
      | _regex_match when (try let regexp = Str.regexp "^\\d+$" in
                                Str.string_match regexp _regex_match 0
                           with _ -> false) -> "number"
      | _regex_match when (try let regexp = Str.regexp "^[a-zA-Z]+$" in
                                Str.string_match regexp _regex_match 0
                           with _ -> false) -> "letters"
      | _regex_match when (try let regexp = Str.regexp "^[a-zA-Z0-9]+$" in
                                Str.string_match regexp _regex_match 0
                           with _ -> false) -> "alphanumeric"
      | _ -> "other"
*)

(** 范围匹配扩展 (@range) - 自定义 *)
let grade_score score =
  match score with
  | _ @range 90 100 -> "A"   (* 90-100分 *)
  | _ @range 80 90 -> "B"    (* 80-89分 *)
  | _ @range 70 80 -> "C"    (* 70-79分 *)
  | _ @range 60 70 -> "D"    (* 60-69分 *)
  | _ -> "F"                 (* 其他分数 *)

(** 展开后代码：
    let grade_score score =
      match score with
      | _range_match when _range_match >= 90 && _range_match <= 100 -> "A"
      | _range_match when _range_match >= 80 && _range_match <= 90 -> "B"
      | _range_match when _range_match >= 70 && _range_match <= 80 -> "C"
      | _range_match when _range_match >= 60 && _range_match <= 70 -> "D"
      | _ -> "F"
*)

(** 类型检查模式扩展 (@is_type) - 自定义 *)
type value = Int_val of int | String_val of string | List_val of value list

let describe_value v =
  match v with
  | _ @is_int -> "integer: " ^ string_of_int (match v with Int_val n -> n | _ -> 0)
  | _ @is_string -> "string: " ^ (match v with String_val s -> s | _ -> "")
  | _ @is_list -> "list of " ^ string_of_int (match v with List_val lst -> List.length lst | _ -> 0) ^ " items"
  | _ -> "unknown type"

(** 展开后代码：
    let describe_value v =
      match v with
      | _type_match when Obj.tag (Obj.repr _type_match) = Obj.int_tag ->
          "integer: " ^ string_of_int (match v with Int_val n -> n | _ -> 0)
      | _type_match when Obj.tag (Obj.repr _type_match) = Obj.string_tag ->
          "string: " ^ (match v with String_val s -> s | _ -> "")
      | _type_match when Obj.tag (Obj.repr _type_match) = Obj.block_tag ->
          "list of " ^ string_of_int (match v with List_val lst -> List.length lst | _ -> 0) ^ " items"
      | _ -> "unknown type"
*)

(** 验证模式扩展 (@valid) - 自定义 *)
type user = { name : string; age : int; email : string }

let validate_user user =
  match user with
  | {name; age; email} @valid (String.length name > 0 &&
                               age >= 18 && age <= 120 &&
                               String.contains email '@') -> true
  | _ -> false

(** 展开后代码：
    let validate_user user =
      match user with
      | {name; age; email} when (String.length name > 0 &&
                                 age >= 18 && age <= 120 &&
                                 String.contains email '@') -> true
      | _ -> false
*)

(** 数据格式解析扩展 (@json, @xml, @yaml) - 自定义 *)
let parse_config config_str =
  match config_str with
  | _ @json -> "JSON格式"    (* JSON解析 *)
  | _ @xml -> "XML格式"      (* XML解析 *)
  | _ @yaml -> "YAML格式"    (* YAML解析 *)
  | _ -> "未知格式"

(** 展开后代码：
    let parse_config config_str =
      match config_str with
      | _format_match when detect_json _format_match -> "JSON格式"
      | _format_match when detect_xml _format_match -> "XML格式"
      | _format_match when detect_yaml _format_match -> "YAML格式"
      | _ -> "未知格式"
*)

(** 📦 第三方 @ 扩展示例（真实可用的） *)

(** 模式绑定扩展 (@bind) - ppx_pattern_bind 第三方库 *)
let process_data data =
  match data with
  | _ @bind (x, y) -> x + y  (* 将数据绑定到变量x,y *)
  | _ -> 0

(** 展开后代码（由 ppx_pattern_bind 生成）：
    let process_data data =
      match data with
      | (_ as _bind_match) when (let x, y = _bind_match in true) ->
          let x, y = _bind_match in x + y
      | _ -> 0
*)

(** 简单的使用示例 *)
let test_at_extensions () =
  let user = { name = "Alice"; age = 30; email = "alice@test.com" } in
  let score = 85 in
  ignore (classify_string "123");
  ignore (grade_score score);
  ignore (describe_value (Int_val 42));
  ignore (validate_user user);
  ignore (process_data (1, 2));
  ignore (parse_config "{}")
