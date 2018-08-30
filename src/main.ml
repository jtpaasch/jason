(** The main entry point to the executable. 
    The executable simply parses a JSON string and prints it out again. *)

let () =
  Cli.cli();

  let expr = Cli.json_string () in
  try
    let res = Json.decode expr in
    Printf.printf "%s\n%!" (Json.encode res)
  with e ->
    match e with
    | Lexer.LexError s -> Printf.printf "Error: %s\n%!" s; exit 1
    | Json.ParseError s -> Printf.printf "Error: %s\n%!" s; exit 1
    | _ -> Printf.printf "Error: %s\n%!" (Printexc.to_string e); exit 1
