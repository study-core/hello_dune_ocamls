(** 自定义 PPX 重写器：数据格式识别扩展
    演示如何实现 @json, @xml, @yaml 等格式识别的模式扩展

    这个扩展允许在模式匹配中自动识别数据格式
*)

open Ppxlib

(** ==================== 辅助函数 ==================== *)

(** 简单的格式检测函数 *)
let detect_json str =
  try
    (* 简单的 JSON 检测：以 { 或 [ 开头，以 } 或 ] 结尾 *)
    let len = String.length str in
    len >= 2 && (
      (str.[0] = '{' && str.[len-1] = '}') ||
      (str.[0] = '[' && str.[len-1] = ']')
    )
  with _ -> false

let detect_xml str =
  try
    (* 简单的 XML 检测：包含 < > 标签 *)
    String.contains str '<' && String.contains str '>'
  with _ -> false

let detect_yaml str =
  try
    (* 简单的 YAML 检测：包含 : 或 - 开头的行 *)
    let lines = String.split_on_char '\n' str in
    List.exists (fun line ->
      let trimmed = String.trim line in
      String.length trimmed > 0 && (
        String.contains trimmed ':' ||
        (String.length trimmed > 0 && trimmed.[0] = '-')
      )
    ) lines
  with _ -> false

(** ==================== 扩展注册 ==================== *)

(** 创建格式检测扩展的辅助函数 *)
let create_format_extension format_name detect_function =
  Extension.declare
    format_name                        (* 扩展的名字：json, xml, yaml *)
    Extension.Context.pattern          (* 扩展的上下文：模式 *)
    Ast_pattern.(pstr nil)            (* 不需要参数 *)
    (fun ~loc ~path:_ () ->
       (* 创建一个变量模式来绑定匹配的字符串 *)
       let var_pat = Ast_helper.Pat.var {txt = "_format_match"; loc} in

       (* 创建 when 条件：调用对应的检测函数 *)
       let detect_expr = match format_name with
         | "json" -> [%expr detect_json _format_match]
         | "xml" -> [%expr detect_xml _format_match]
         | "yaml" -> [%expr detect_yaml _format_match]
         | _ -> failwith "Unknown format"
       in

       let when_expr = detect_expr in

       (* 返回带条件的模式 *)
       Ast_helper.Pat.when_ var_pat when_expr
    )

(** 创建各个格式的扩展 *)
let json_extension = create_format_extension "json" detect_json
let xml_extension = create_format_extension "xml" detect_xml
let yaml_extension = create_format_extension "yaml" detect_yaml

(** 注册重写器 *)
let () = Driver.register_transformation "formats" ~extensions:[
  json_extension;
  xml_extension;
  yaml_extension;
]

(** ==================== 使用示例 ==================== *)

(** 在你的代码中使用：

    let parse_config config_str =
      match config_str with
      | _ @json -> parse_json config_str
      | _ @xml -> parse_xml config_str
      | _ @yaml -> parse_yaml config_str
      | _ -> failwith "Unknown format"

    (* 编译后会转换为：
       let parse_config config_str =
         match config_str with
         | _format_match when detect_json _format_match -> parse_json config_str
         | _format_match when detect_xml _format_match -> parse_xml config_str
         | _format_match when detect_yaml _format_match -> parse_yaml config_str
         | _ -> failwith "Unknown format"
    *)

*)

(** ==================== 扩展说明 ==================== *)

(** 这个格式识别扩展演示了：

    1. 如何实现自动的数据格式检测
    2. 如何创建多个相关的模式扩展
    3. 如何集成简单的解析逻辑
    4. 如何处理不同数据格式的自动识别

    在实际应用中，可以集成更强大的格式检测库

    生成的代码示例：
    输入：  | _ @json -> parse_json str
           | _ @xml -> parse_xml str
           | _ @yaml -> parse_yaml str

    输出：  | _format_match when detect_json _format_match -> parse_json str
           | _format_match when detect_xml _format_match -> parse_xml str
           | _format_match when detect_yaml _format_match -> parse_yaml str
*)
