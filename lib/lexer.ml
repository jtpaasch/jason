(** Implements {!Lexer}. *)

exception LexError of string

let slice s n =
  let len = String.length s in
  match len >= n with
  | false -> ""
  | true -> String.sub s n (len - n)

let get_null s =
  let len = String.length s in
  match len >= 4 with
  | true -> Token.Null, slice s 4
  | false -> raise (LexError (Printf.sprintf "Unrecognized '%s'" s))

let get_true s =
  let len = String.length s in
  match len >= 4 with
  | true -> Token.True, slice s 4
  | false -> raise (LexError (Printf.sprintf "Unrecognized '%s'" s))

let get_false s =
  let len = String.length s in
  match len >= 5 with
  | true -> Token.False, slice s 5
  | false -> raise (LexError (Printf.sprintf "Unrecognized '%s'" s))

let rec build_number s acc =
  match String.length s > 0 with
  | false -> acc, s
  | true ->
    begin
      match s.[0] with
      | '0'..'9' ->
        begin
          let s' = slice s 1 in
          let acc' = Printf.sprintf "%s%c" acc s.[0] in
          build_number s' acc'
        end
      | '.' ->
        begin
          let s' = slice s 1 in
          match String.length s' > 0 with
          | false -> raise (LexError (Printf.sprintf "Expecting digit after dot in '%s'" s))
          | true ->
            begin
              match s'.[0] with
              | '0'..'9' ->
                begin
                  let s'' = slice s' 1 in
                  let acc' = Printf.sprintf "%s%c%c" acc s.[0] s'.[0] in
                  build_number s'' acc'
                end
              | _ -> raise (LexError (Printf.sprintf "Expecting digit after dot in '%s'" s))
            end
        end
      | 'e' ->
        begin
          let s' = slice s 1 in
          match String.length s' > 0 with
          | false -> raise (LexError (Printf.sprintf "Expecting digit after 'e' in '%s'" s))
          | true ->
            begin
              match s'.[0] with
              | '0'..'9' ->
                begin
                  let s'' = slice s' 1 in
                  let acc' = Printf.sprintf "%s%c%c" acc s.[0] s'.[0] in
                  build_number s'' acc'
                end
              | _ -> raise (LexError (Printf.sprintf "Expecting digit after 'e' in '%s'" s))
            end
        end
      | 'E' ->
        begin
          let s' = slice s 1 in
          match String.length s' > 0 with
          | false -> raise (LexError (Printf.sprintf "Expecting digit after 'E' in '%s'" s))
          | true ->
            begin
              match s'.[0] with
              | '0'..'9' ->
                begin
                  let s'' = slice s' 1 in
                  let acc' = Printf.sprintf "%s%c%c" acc s.[0] s'.[0] in
                  build_number s'' acc'
                end
              | _ -> raise (LexError (Printf.sprintf "Expecting digit after 'E' in '%s'" s))
            end
        end
      | _ -> acc, s
    end

let get_number s =
  let value, s' = build_number s "" in
  Token.Number value, s'

let get_neg_number s =
  let s' = slice s 1 in
  match String.length s' > 0 with
  | false -> raise (LexError "Expecting number after minus symbol")
  | true ->
    begin
      match s'.[0] with
      | '0'..'9' ->
        begin
          let value, s'' = build_number s' "" in
          let neg_value = Printf.sprintf "-%s" value in
          Token.Number neg_value, s''
        end
      | _ -> raise (LexError "Expecting number after minus symbol")
    end

let rec build_string s acc =
  match String.length s > 0 with
  | false -> acc, s
  | true ->
    begin
      match s.[0] with
      | '"' ->
        begin
          let s' = slice s 1 in
          let acc' = Printf.sprintf "%s%c" acc s.[0] in
          acc', s'
        end
      | '\\' ->
        begin
          let s' = slice s 1 in
          match String.length s' > 0 with
          | false ->
            raise (LexError (Printf.sprintf "Expecting control character after slash in '%s'" s))
          | true -> 
            begin
              match s'.[0] with
              | '"'
              | '\\'
              | '/'
              | 'b'
              | 'f'
              | 'n'
              | 'r'
              | 't' ->
                begin
                  let s'' = slice s' 1 in
                  let acc' = Printf.sprintf "%s%c%c" acc s.[0] s'.[0] in
                  build_string s'' acc'
                end
              | 'u' ->
                begin
                  let s'' = slice s' 1 in
                  match String.length s'' > 3 with
                  | false ->
                    raise (LexError (Printf.sprintf "Expecting 4 hexadecimal digits after \\u in '%s'" s))
                  | true ->
                    begin
                      let hex_chars = [
                        '0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9';
                        'a'; 'b'; 'c'; 'd'; 'e'; 'f';
                        'A'; 'B'; 'C'; 'D'; 'E'; 'F';
                        ] in
                      let matched_chars = 
                        List.filter (fun c -> List.mem c hex_chars) [s''.[0]; s''.[1]; s''.[2]; s''.[3]] in
                      match List.length matched_chars = 4 with
                      | true -> 
                        begin
                          let code = String.sub s'' 0 4 in
                          let s''' = slice s'' 4 in
                          let acc' = Printf.sprintf "%s%c%c%s" acc s.[0] s'.[0] code in
                          build_string s''' acc'
                        end
                      | false ->
                        raise (LexError (Printf.sprintf "Expecting 4 hexadecimal digits after \\u in '%s'" s))
                    end
                end
              | _ ->
                raise (LexError (Printf.sprintf "Expecting control character after slash in '%s'" s))
            end
        end
      | _ ->
        begin
          let s' = slice s 1 in
          let acc' = Printf.sprintf "%s%c" acc s.[0] in
          build_string s' acc'
        end
    end

let get_string s =
  let value, s' = build_string s "" in
  match String.length value < 1 with
  | true -> raise (LexError (Printf.sprintf "Expecting string after opening quotation mark in '%s'" s))
  | false ->
    begin
      let last_char = value.[String.length value - 1] in
      match last_char with
      | '"' -> 
        begin
          let value' = String.sub value 0 (String.length value - 1) in
          Token.String value', s'
        end
      | _ -> raise (LexError (Printf.sprintf "Expecting closing quotation mark in '%s'" s))
    end

let rec lex s acc =
  match String.length s > 0 with
  | false -> List.append acc [Token.Eof]
  | true ->
    begin
      match s.[0] with
      | ' '
      | '\t'
      | '\b'
      | '\r'
      | '\n' -> lex (slice s 1) acc
      | 'n' ->
        begin
          let token, the_rest = get_null s in
          let new_acc = List.append acc [token] in
          lex the_rest new_acc
        end
      | 't' ->
        begin
          let token, the_rest = get_true s in
          let new_acc = List.append acc [token] in
          lex the_rest new_acc
        end
      | 'f' ->
        begin
          let token, the_rest = get_false s in
          let new_acc = List.append acc [token] in
          lex the_rest new_acc
        end
      | '-' ->
        begin
          let token, the_rest = get_neg_number s in
          let new_acc = List.append acc [token] in
          lex the_rest new_acc
        end
      | '0'..'9' ->
        begin
          let token, the_rest = get_number s in
          let new_acc = List.append acc [token] in
          lex the_rest new_acc
        end
      | '"' ->
        begin
          let token, the_rest = get_string (slice s 1) in
          let new_acc = List.append acc [token] in
          lex the_rest new_acc
        end
      | '[' ->
        begin
          let new_acc = List.append acc [Token.L_array_bracket] in
          lex (slice s 1) new_acc
        end
      | ']' ->
        begin
          let new_acc = List.append acc [Token.R_array_bracket] in
          lex (slice s 1) new_acc
        end
      | '{' ->
        begin
          let new_acc = List.append acc [Token.L_object_bracket] in
          lex (slice s 1) new_acc
        end
      | '}' ->
        begin
          let new_acc = List.append acc [Token.R_object_bracket] in
          lex (slice s 1) new_acc
        end
      | ':' ->
        begin
          let new_acc = List.append acc [Token.Colon] in
          lex (slice s 1) new_acc
        end
      | ',' ->
        begin
          let new_acc = List.append acc [Token.Comma] in
          lex (slice s 1) new_acc
        end
      | _ -> raise (LexError (Printf.sprintf "Lexing error on: '%s'" s))
    end

