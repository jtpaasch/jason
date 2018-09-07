(** Decodes a string of Json into an AST, or encodes an AST into a JSON string. *)

(** Thrown when there is a parse error. *)
exception ParseError of string

(** Thrown when you try to access a JSON type that is not in the AST. *)
exception NotSuch of string

(** Thrown when you try to access a key in a JSON object that doesn't exist. *)
exception NoSuchKey of string

(** The AST. *)
type t =
  | Json_end
  | Json_null
  | Json_true
  | Json_false
  | Json_number of string
  | Json_string of string
  | Json_array of t list
  | Json_object of (string * t) list

(** Decodes a JSON string into the AST. *)
val decode : string -> t

(** Takes an AST and encodes it as a JSON string. *)
val encode : t -> string

(** Extract ["EOF"] from the [t], if [t] is [Json_end]. *)
val eof : t -> string option
val eof_exn : t -> string

(** Extract ["null"] from [t], if [t] is [Json_null]. *)
val null : t -> string option
val null_exn : t -> string

(** Extract [true] from [t], if [t] is [Json_true]. *)
val bool_true : t -> bool option
val bool_true_exn : t -> bool

(** Extract [false] from [t], if [t] is [Json_false]. *)
val bool_false : t -> bool option
val bool_false_exn : t -> bool

(** Extract a number (as a string) from [t], if [t] is [Json_number]. 
    The string can be converted with [int_of_string] or [float_of_int]. *)
val num : t -> string option
val num_exn : t -> string

(** Extract the string value from [t], if [t] is [Json_string]. *)
val str : t -> string option
val str_exn : t -> string

(** Extract the list of values from [t], if [t] is [Json_array]. *)
val arr : t -> t list option
val arr_exn : t -> t list

(** Extract the list of key/value pairs from [t], if [t] is [Json_object]. *)
val obj : t -> (string * t) list option
val obj_exn : t -> (string * t) list

(** Extract the value for a matching string key from [t], 
    if [t] is a list of key/value pairs from a [Json_object]. *)
val value : (string * t) list -> string -> t option
val value_exn : (string * t) list -> string -> t
