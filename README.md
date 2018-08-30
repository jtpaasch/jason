# Jason

A simple JSON decoder/encoder.


## Build

Clone the repo:

    git clone https://github.com/jtpaasch/jason.git
    cd jason

Run `oasis setup`, then build it and install:

    oasis setup
    make
    make install

Try the executable:

    jason --help
    jason '{"foo": "bar"}'


## Using the library

For instance, load the library in `utop`:

    #use "topfind";;
    #require "jason_lib";;

Decode a JSON string:

  let raw_json = "{\"foo\":\"bar\"}";;
  let j = Json.decode raw_json;;

Encode it back into a string:

  Json.encode j;;


