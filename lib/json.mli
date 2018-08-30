(** Decodes a string of Json into an AST, or encodes an AST into a JSON string. *)

exception ParseError of string

type t =
  | Json_end
  | Json_null
  | Json_true
  | Json_false
  | Json_number of string
  | Json_string of string
  | Json_array of t list
  | Json_object of (string * t) list

val decode : string -> t

val encode : t -> string
