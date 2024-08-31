## odin_toml, toml parser for odin
> [!CAUTION]
> still in progress, not for use yet!

## example
```toml
# example.toml
username = "lumixing"
admin = true
"favorite color" = "Blue"
```

```odin
package example

import "core:fmt"
import toml "odin_toml"

main :: proc() {
    tree, err := toml.parse_file("example.toml")
    if err != nil {
        fmt.panicf("%v", err)
    }

    username, ok := toml.get(tree, "username", string)
    if ok {
        fmt.println(username) // lumixing
    }

    if admin, ok := toml.get(tree, "admin", bool); admin && ok {
        fmt.println(username, "is an admin")
    }
}
```

```odin
package example

import "core:fmt"
import toml "odin_toml"

MyStruct :: struct {
    username:  string,
    password:  string, `default=nopass`
    admin:     bool,
    fav_color: string, `name=favorite color`
}

main :: proc() {
    tree, err := toml.parse_file("example.toml")
    if err != nil {
        fmt.panicf("%v", err)
    }

    my_struct: MyStruct
    toml.unmarshal(&my_struct, tree)

    fmt.println(my_struct.username)  // lumixing
    fmt.println(my_struct.password)  // nopass
    fmt.println(my_struct.fav_color) // Blue
}
```

## spec completion list
spec: https://toml.io/en/v1.0.0  
- [x] comments
- [x] bare keys
- [x] quoted keys*
- [ ] dotted keys
- [ ] float as key
---
- [x] basic strings*(not all escapes)
- [ ] multi-line basic strings
- [x] literal strings
- [ ] multi-line literal strings
---
- [ ] unsigned integers
- [ ] signed integers
- [ ] underscored integers
- [ ] hex 0x
- [ ] octal 0o
- [ ] binary 0b
---
- [ ] unsigned floats
- [ ] signed floats
- [ ] exponent floats
- [ ] fractional exponent floats
- [ ] underscored floats
- [ ] inf
- [ ] nan
---
- [x] booleans
---
- [ ] offset date-time
- [ ] no T delimited offset date-time
- [ ] local date-time
- [ ] millisecond precise local
- [ ] date-time
- [ ] local date
- [ ] local time
- [ ] millisecond precise local time
---
- [ ] unnested arrays
- [ ] nested arrays
- [ ] whitespace formats
- [ ] trailing comma
---
- [ ] tables
- [ ] inline tables
- [ ] arrays of tables

also check out: https://github.com/Up05/toml_parser
