(** Scans a string and produces a list of tokens. *)

exception LexError of string

(** Takes a string and an initial string accumulator, and returns a list of tokens. *) 
val lex : string -> string -> t list
