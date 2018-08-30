(** Manages/defines the CLI for the program. *)

(** Parses the command line arguments. *)
val cli : unit -> unit

(** Retrieves the value provided at the command line 
    for the JSON_STRING argument. *)
val json_string : unit -> string
