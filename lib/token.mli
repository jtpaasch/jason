(** Tokens the lexer can identify. *)

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

val string_of : t -> string
