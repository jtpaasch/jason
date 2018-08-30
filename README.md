# Jason

A simple JSON decoder/encoder.


## Build

Clone the repo:

    git clone https://github.com/jtpaasch/jason.git
    cd jason

Run `oasis setup` and build:

    oasis setup
    make

Try the executable:

    jason --help
    jason '{"foo": "bar"}'


## Using the library

```
let () =
  let raw_json = "{\"foo\":\"bar\"}" in
  let j = Json.decode raw_json;

  Printf.printf "%s\n%!" (Json.encode j)
```

