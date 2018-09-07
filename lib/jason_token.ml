(** Implements {!Token}. *)

type t =
  | L_array_bracket
  | R_array_bracket
  | L_object_bracket
  | R_object_bracket
  | Colon
  | Comma
  | Eof
  | Null
  | True
  | False
  | Number of string
  | String of string


let string_of t =
  match t with
  | L_array_bracket -> "<TK [>"
  | R_array_bracket -> "<TK ]>"
  | L_object_bracket -> "<TK {>"
  | R_object_bracket -> "<TK }>"
  | Colon -> "<TK :>"
  | Comma -> "<TK ,>"
  | Eof -> "<TK Eof>"
  | Null -> "<TK null>"
  | True -> "<TK true>"
  | False -> "<TK false>"
  | Number s -> Printf.sprintf "<TK '%s'>" s
  | String s -> Printf.sprintf "<TK '%s'>" s

