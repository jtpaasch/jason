(** Implements {!Json}. *)

module Token = Jason_token
module Lexer = Jason_lexer

exception ParseError of string
exception NotSuch of string
exception NoSuchKey of string

type t =
  | Json_end
  | Json_null
  | Json_true
  | Json_false
  | Json_number of string
  | Json_string of string
  | Json_array of t list
  | Json_object of (string * t) list

let rec string_of t =
  match t with
  | Json_end -> ""
  | Json_null -> "null"
  | Json_true -> "true"
  | Json_false -> "false"
  | Json_number s -> Printf.sprintf "%s" s
  | Json_string s -> Printf.sprintf "\"%s\"" s
  | Json_array l ->
    begin
      let mapped_strs = List.map string_of l in
      let concatenated_strs = String.concat ", " mapped_strs in
      Printf.sprintf "[%s]" concatenated_strs
    end
  | Json_object l ->
    begin
      let mapped_strs = List.map (fun (k, v) -> Printf.sprintf "\"%s\": %s" k (string_of v)) l in
      let concatenated_strs = String.concat ", " mapped_strs in
      Printf.sprintf "{%s}" concatenated_strs 
    end

let check_for_junk res tokens msg =
  match tokens with
  | [] -> res
  | [Token.Eof] -> res
  | Token.Comma :: _ -> res
  | Token.R_array_bracket :: _ -> res
  | Token.R_object_bracket :: _ -> res
  | _ -> raise (ParseError msg)

let rec parse_array_elements tokens f acc =
  let value, tokens = f tokens in
  let new_acc = List.append acc [value] in
  match tokens with
  | Token.R_array_bracket :: the_rest -> new_acc, the_rest
  | Token.Comma :: the_rest -> parse_array_elements the_rest f new_acc
  | _ -> raise (ParseError "Expecting comma or closing array bracket")

let parse_array tokens f =
  match tokens with
  | [] -> raise (ParseError "Expecting array elements or closing bracket")
  | Token.R_array_bracket :: the_rest -> [], the_rest
  | _ -> parse_array_elements tokens f []

let rec parse_object_entries tokens f acc =
  let key, value, tokens = match tokens with
  | Token.String s :: Token.Colon :: the_rest -> 
    begin
      let value, the_rest_rest = f the_rest in
      s, value, the_rest_rest
    end
  | _ -> raise (ParseError "Expecting key/value pair in object") in
  let new_acc = List.append acc [(key, value)] in
  match tokens with
  | Token.R_object_bracket :: the_rest -> new_acc, the_rest
  | Token.Comma :: the_rest -> parse_object_entries the_rest f new_acc
  | _ -> raise (ParseError "Expecting comma or closing object bracket")

let parse_object tokens f =
  match tokens with
  | [] -> raise (ParseError "Expecting object entries or closing bracket")
  | Token.R_object_bracket :: the_rest -> [], the_rest
  | _ -> parse_object_entries tokens f []

let rec parse tokens =
  match tokens with
  | [] -> (Json_end, [])
  | Token.Null :: the_rest ->
    begin
      let res = (Json_null, the_rest) in
      let msg = "Junk after null" in
      check_for_junk res the_rest msg
    end
  | Token.True :: the_rest ->
    begin
      let res = (Json_true, the_rest) in
      let msg = "Junk after true" in
      check_for_junk res the_rest msg
    end
  | Token.False :: the_rest ->
    begin
      let res = (Json_false, the_rest) in
      let msg = "Junk after false" in
      check_for_junk res the_rest msg
    end
  | Token.Number n :: the_rest ->
    begin
      let res = (Json_number n, the_rest) in
      let msg = "Junk after number" in
      check_for_junk res the_rest msg
    end
  | Token.String s :: the_rest ->
    begin
      let res = (Json_string s, the_rest) in
      let msg = "Junk after string" in
      check_for_junk res the_rest msg
    end
  | Token.L_array_bracket :: the_rest -> 
    begin
      let elements, the_rest_rest = parse_array the_rest parse in
      let res = Json_array elements, the_rest_rest in
      let msg = "Junk after array" in
      check_for_junk res the_rest_rest msg
    end
  | Token.L_object_bracket :: the_rest ->
    begin
      let entries, the_rest_rest = parse_object the_rest parse in
      let res = Json_object entries, the_rest_rest in
      let msg = "Junk after object" in
      check_for_junk res the_rest_rest msg
    end
  | _ -> raise (ParseError (Printf.sprintf "Expected JSON value."))

let decode s =
  let tokens = Lexer.lex s [] in
  let res, _ = parse tokens in
  res

let encode j = string_of j

let eof t =
  match t with
  | Json_end -> Some "EOF"
  | _ -> None

let eof_exn t =
  match eof t with
  | Some s -> s
  | None ->
    begin
      let msg = Printf.sprintf "Not JSON EOF/end: '%s'" (encode t) in
      raise (NotSuch msg)
    end

let null t =
  match t with
  | Json_null -> Some "null"
  | _ -> None

let null_exn t =
  match null t with
  | Some s -> s
  | None ->
    begin
      let msg = Printf.sprintf "Not null: '%s'" (encode t) in
      raise (NotSuch msg)
    end

let bool_true t =
  match t with
  | Json_true -> Some true
  | _ -> None

let bool_true_exn t =
  match bool_true t with
  | Some b -> b
  | None ->
    begin
      let msg = Printf.sprintf "Not the boolean true: '%s'" (encode t) in
      raise (NotSuch msg)
    end

let bool_false t =
  match t with
  | Json_false -> Some false
  | _ -> None

let bool_false_exn t =
  match bool_false t with
  | Some b -> b
  | None ->
    begin
      let msg = Printf.sprintf "Not the boolean false: '%s'" (encode t) in
      raise (NotSuch msg)
    end

let num t =
  match t with
  | Json_number s -> Some s
  | _ -> None

let num_exn t =
  match num t with
  | Some s -> s
  | None ->
    begin
      let msg = Printf.sprintf "Not a number: '%s'" (encode t) in
      raise (NotSuch msg)
    end

let str t =
  match t with
  | Json_string s -> Some s
  | _ -> None

let str_exn t =
  match str t with
  | Some s -> s
  | None ->
    begin
      let msg = Printf.sprintf "Not a string: '%s'" (encode t) in
      raise (NotSuch msg)
    end

let arr t =
  match t with
  | Json_array a -> Some a
  | _ -> None

let arr_exn t =
  match arr t with
  | Some a -> a
  | None ->
    begin
      let msg = Printf.sprintf "Not an array: '%s'" (encode t) in
      raise (NotSuch msg)
    end

let obj t =
  match t with
  | Json_object o -> Some o
  | _ -> None

let obj_exn t =
  match obj t with
  | Some o -> o
  | None ->
    begin
      let msg = Printf.sprintf "Not an object: '%s'" (encode t) in
      raise (NotSuch msg)
    end

let rec value o k =
  match o with
  | [] -> None
  | (k', v) :: tl ->
    begin
      match k = k' with
      | true -> Some v
      | false -> value tl k
    end

let value_exn o k =
  match value o k with
  | Some v -> v
  | None ->
    begin
      let msg = Printf.sprintf "Key '%s' not found." k in
      raise (NoSuchKey msg)
    end

