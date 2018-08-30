(** Scans a string and produces a list of tokens. *)

exception LexError of string

(** Takes a string and a {!Token.t} accumulator, and returns a {!Token.t} list. *) 
val lex : string -> Token.t list -> Token.t list
