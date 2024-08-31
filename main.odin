package toml

import "core:flags"
import "core:fmt"
import "core:os"
import "core:reflect"

Test :: struct {
	username: string,
	friend:   string,
	genius:   bool,
	dev:      string `default=a default value!`,
}

main :: proc() {
	data, ok := os.read_entire_file("examples/test.toml")
	if !ok {
		panic("could not open file")
	}

	lexer := new(Lexer)
	lexer.source = data
	lexer_scan(lexer)

	for token in lexer.tokens {
		#partial switch v in token.value {
		case string:
			fmt.printf("%v(%q) ", token.type, token.value)
		case nil:
			#partial switch token.type {
			case .Newline:
				fmt.println("\\")
			case .White:
				fmt.print("~ ")
			case .Equals:
				fmt.print("= ")
			case .Dot:
				fmt.print(". ")
			case .EOF:
				fmt.println("EOF\n")
			case:
				fmt.print(token.type, "")
			}
		case:
			fmt.printf("%v(%v) ", token.type, token.value)
		}
	}

	parser := new(Parser)
	parser.tokens = lexer.tokens[:]
	parser_scan(parser)

	for expr in parser.expr {
		fmt.println(expr)
	}

	tree := eval(parser.expr[:])

	test: Test
	unmarshal(&test, tree)
	fmt.println(test)
}

unmarshal :: proc(model: ^$T, tree: Tree) {
	for field in reflect.struct_fields_zipped(Test) {
		switch field.type.id {
		case string:
			ptr := cast(^string)(cast(uintptr)model + field.offset)
			if value, ok := get(tree, field.name, string); ok {
				ptr^ = value
			} else {
				if v, ok := flags.get_subtag(string(field.tag), "default"); ok {
					ptr^ = v
				}
			}
		case bool:
			if value, ok := get(tree, field.name, bool); ok {
				ptr := cast(^bool)(cast(uintptr)model + field.offset)
				ptr^ = value
			}
		}
	}
}
