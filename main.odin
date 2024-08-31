package toml

import "core:fmt"
import "core:os"

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
	fmt.println(get(tree, "friend", string))
}
