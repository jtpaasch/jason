(** The main entry point to the executable. 
    The executable simply parses a JSON string and prints it out again. *)

module Lexer = Jason_lexer

let () =
  Cli.cli();

  let expr = Cli.json_string () in
  try
    let res = Jason.decode expr in
    Printf.printf "%s\n%!" (Jason.encode res)
  with e ->
    match e with
    | Lexer.LexError s -> Printf.printf "Error: %s\n%!" s; exit 1
    | Jason.ParseError s -> Printf.printf "Error: %s\n%!" s; exit 1
    | _ -> Printf.printf "Error: %s\n%!" (Printexc.to_string e); exit 1
