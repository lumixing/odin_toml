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

also check out: https://github.com/Up05/toml_parser
