package toml

import "core:fmt"

Parser :: struct {
	tokens:  []Token,
	expr:    [dynamic]Expr,
	start:   int,
	current: int,
}

parser_scan :: proc(parser: ^Parser) {
	for !parser_is_end(parser^) {
		parser.start = parser.current
		token := parser_advance(parser)

		#partial switch token.type {
		case .White, .Newline, .EOF:
		case .Ident:
			name := token.value.(string)
			if parser_peek(parser^).type == .White {
				parser_advance(parser)
			}
			if parser_advance(parser).type != .Equals {
				fmt.panicf("expected equals")
			}
			if parser_peek(parser^).type == .White {
				parser_advance(parser)
			}
			value: Value
			if parser_peek(parser^).type == .String {
				value = parser_peek(parser^).value.(string)
			} else if parser_peek(parser^).type == .Bool {
				value = parser_peek(parser^).value.(bool)
			} else {
				fmt.panicf("expected bool or string")
			}
			parser_advance(parser)
			if parser_advance(parser).type != .Newline {
				fmt.panicf("expected newline")
			}
			append(&parser.expr, Keyval{name, value})
		case:
			fmt.panicf("unexpected: %v", token)
		}
	}
}

@(private = "file")
parser_peek :: proc(parser: Parser) -> (Token, bool) #optional_ok {
	if parser_is_end(parser) {
		return {}, false
	}

	return parser.tokens[parser.current], true
}

@(private = "file")
parser_advance :: proc(parser: ^Parser) -> (Token, bool) #optional_ok {
	defer parser.current += 1
	return parser_peek(parser^)
}

@(private = "file")
parser_is_end :: proc(parser: Parser) -> bool {
	return parser.current >= len(parser.tokens)
}
