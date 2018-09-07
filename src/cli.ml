(** Implements {!Cli}. *)

let program_name = "jason"
let program_version = "0.1"

let json_string_value = ref ""
let json_string = fun () -> !json_string_value

let help_hint = fun () -> Printf.sprintf "See %s --help." program_name

let usage = fun () -> Printf.sprintf "USAGE: %s JSON_STRING" program_name

let version = fun () -> Printf.printf "%s %s\n%!" program_name program_version; exit 0

let spec = [
  ("--version", Arg.Unit version, "Print the version and exit.")
]

let handle_args arg =
  match arg with
  | _ ->
    begin
      match json_string () with
      | "" -> json_string_value := arg
      | _ ->
        begin
          Printf.printf "Error. Unrecognized argument: '%s'. %s\n%!" arg (help_hint ());
          exit 1
        end
    end

let check () = 
  match json_string () with
  | "" -> 
    begin
      Printf.printf "Specify a JSON_STRING. %s\n%!" (help_hint ());
      exit 1
    end
  | _ -> ()

let cli () =
  Arg.parse spec handle_args (usage ());
  check ()
