package toml

import "core:flags"
import "core:fmt"
import "core:os"
import "core:reflect"

Test :: struct {
	username:  string,
	friend:    string `default=a default value!`,
	genius:    bool,
	cool_name: string `name=cool name`,
}

main :: proc() {
	tree, err := parse_file("examples/test.toml", {.PrintTokens, .PrintExpressions})
	if err != nil {
		fmt.panicf("%v", err)
	}
	test: Test
	unmarshal(&test, tree)
	fmt.println(test)
}

ParseFlag :: enum {
	PrintTokens,
	PrintExpressions,
}

ParseFlags :: distinct bit_set[ParseFlag]

Error :: struct {
	line, column: int,
	type:         ErrorType,
}

ErrorType :: enum {
	// lexer errors
	UnterminatedString,
	InvalidEscape,
	InvalidReturn,
	InvalidCharacter,
	// parser errors
	MissingKey,
	MissingValue,
	MissingNewline,
	MissingEquals,
	UnknownError,
}

parse_file :: proc(filename: string, flags: ParseFlags = {}) -> (Tree, Maybe(Error)) {
	data, ok := os.read_entire_file("examples/test.toml")
	if !ok {
		panic("could not open file")
	}

	lexer := new(Lexer)
	lexer.source = data
	err := lexer_scan(lexer)
	if err != nil {
		return {}, err
	}

	if .PrintTokens in flags {
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
	}

	parser := new(Parser)
	parser.source = data
	parser.tokens = lexer.tokens[:]
	err = parser_scan(parser)
	if err != nil {
		return {}, err
	}

	if .PrintExpressions in flags {
		for expr in parser.expr {
			fmt.println(expr)
		}
		fmt.println()
	}

	tree := eval(parser.expr[:])
	return tree, nil
}

unmarshal :: proc(model: ^$T, tree: Tree) {
	for field in reflect.struct_fields_zipped(Test) {
		name := field.name
		if v, ok := flags.get_subtag(string(field.tag), "name"); ok {
			name = v
		}

		switch field.type.id {
		case string:
			ptr := cast(^string)(cast(uintptr)model + field.offset)
			if value, ok := get(tree, name, string); ok {
				ptr^ = value
			} else {
				if v, ok := flags.get_subtag(string(field.tag), "default"); ok {
					ptr^ = v
				}
			}
		case bool:
			if value, ok := get(tree, name, bool); ok {
				ptr := cast(^bool)(cast(uintptr)model + field.offset)
				ptr^ = value
			}
		}
	}
}

@(private)
get_line_col :: proc(source: []u8, lo: int) -> (line, col: int) {
	line = 1
	col = 1
	for i in 0 ..< lo {
		if source[i] == '\n' {
			line += 1
			col = 1
		} else {
			col += 1
		}
	}
	return line, col
}
