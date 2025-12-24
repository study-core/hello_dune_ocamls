(** @ 扩展示例 - 模式级别的实际用法 *)

(** 正则表达式模式匹配 *)
let classify_string s =
  match s with
  | _ when Str.string_match (Str.regexp "^\\d+$") s 0 -> "number"
  | _ when Str.string_match (Str.regexp "^[a-zA-Z]+$") s 0 -> "letters"
  | _ when Str.string_match (Str.regexp "^[a-zA-Z0-9]+$") s 0 -> "alphanumeric"
  | _ -> "other"

(** 范围匹配 *)
let grade_score score =
  match score with
  | _ when score >= 90 && score <= 100 -> "A"
  | _ when score >= 80 && score < 90 -> "B"
  | _ when score >= 70 && score < 80 -> "C"
  | _ when score >= 60 && score < 70 -> "D"
  | _ -> "F"

(** 类型检查模式 *)
type value = Int_val of int | String_val of string | List_val of value list

let describe_value v =
  match v with
  | Int_val n -> "integer: " ^ string_of_int n
  | String_val s -> "string: " ^ s
  | List_val lst -> "list of " ^ string_of_int (List.length lst) ^ " items"

(** 验证模式 *)
type user = { name : string; age : int; email : string }

let validate_user user =
  match user with
  | { name; age; email } when String.length name > 0 &&
                              age >= 18 && age <= 120 &&
                              String.contains email '@' -> true
  | _ -> false

(** 使用示例 *)
let () =
  print_endline (classify_string "123");
  print_endline (grade_score 85);
  print_endline (describe_value (Int_val 42));
  print_endline (string_of_bool (validate_user { name = "Alice"; age = 30; email = "alice@test.com" }))