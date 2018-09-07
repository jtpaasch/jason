# Jason

A simple JSON decoder/encoder.


## Build

Clone the repo:

    git clone https://github.com/jtpaasch/jason.git
    cd jason

Run `oasis setup`, then build it and install:

    oasis setup
    make
    sudo make install

Try the executable:

    jason --version
    jason --help
    jason '{"foo": "bar"}'

The executable simply decodes and re-encodes the string you pass it.

Uninstall:

    sudo make uninstall
    make clean
    make distclean
    rm -rf configure Makefile myocamlbuild.ml setup.ml _tags lib/META lib/*.mld* lib/*.mll*


## Using the library

The library name (for `ocamlfind') is `jason_lib`.
Load it in `utop`, for instance:

    #use "topfind";;
    #require "jason_lib";;

Decode a JSON string:

    let raw_json = "{\"foo\":\"bar\"}";;
    let j = Jason.decode raw_json;;

Encode it back into a string:

    let restored_json = Jason.encode j;;
    Printf.printf "%s\n%!" restored_json;;

Decode another JSON string:

    let raw_json =
      "{\"foo\": \"bar\",\"bip\": null, \"bap\": true, \"biz\": [1, -23, 45.24, 0.00217e34]}";;
    let j = Jason.decode raw_json;;

Extract the object:

    let o = Jason.obj_exn j;;

Get the value for the key `foo`:

    let foo = Jason.value_exn o "foo";;

Extract the string value:

    let foo_str = Jason.str_exn foo;;

Get the value for the key `bip`:

    let bip = Jason.value_exn o "bip";;

Extract the null value:

    let bip_null = Jason.null_exn bip;;

Get the value for the key `bap`:

    let bap = Jason.value_exn o "bap";;

Extract the `true` value:

    let bip_true = Jason.bool_true_exn bap;;

Get the value for the key `biz`:

    let biz = Jason.value_exn o "biz";;

Extract the list:

    let biz_arr = Jason.arr_exn biz;;

Get each element of the list individually:

    let biz_1st = List.nth biz_arr 0;;
    let biz_2nd = List.nth biz_arr 1;;
    let biz_3rd = List.nth biz_arr 2;;
    let biz_4th = List.nth biz_arr 3;;

Extract these numbers:

    let biz_1st_num = Jason.num_exn biz_1st;;
    let biz_2nd_num = Jason.num_exn biz_2nd;;
    let biz_3rd_num = Jason.num_exn biz_3rd;;
    let biz_4th_num = Jason.num_exn biz_4th;;
    
Extracted `Jason_number`s are strings, since JSON represents integers
and floats as the same data type, with negation signs and `e` expressions.
To compute with these values in OCaml, convert them to ints or floats
(but watch out for floats or integers larger than the values that OCaml
can actually convert).

    let biz_1st_int = int_of_string biz_1st_num;;
    let biz_2nd_int = int_of_string biz_2nd_num;;
    let biz_3rd_float = float_of_string biz_3rd_num;;
    let biz_4th_float = float_of_string biz_4th_num;;

There are none `_exn` versions for all these functions.
See `lib/jason.mli` for the full module interface.