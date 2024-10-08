package toml

@(private)
Parser :: struct {
	source:  []u8,
	tokens:  []Token,
	expr:    [dynamic]Expr,
	start:   int,
	current: int,
}

@(private)
parser_scan :: proc(parser: ^Parser) -> Maybe(Error) {
	for !parser_is_end(parser^) {
		parser.start = parser.current
		token := parser_advance(parser)

		#partial switch token.type {
		case .White, .Newline, .EOF:
		case .Ident, .String:
			name := token.value.(string)

			parser_white(parser)
			if err := parser_expect(parser, .Equals); err != nil {
				return err
			}
			parser_white(parser)

			value: Value
			if parser_peek(parser^).type == .String {
				value = parser_peek(parser^).value.(string)
			} else if parser_peek(parser^).type == .Bool {
				value = parser_peek(parser^).value.(bool)
			} else if parser_peek(parser^).type == .Integer {
				value = parser_peek(parser^).value.(i64)
			} else {
				return parser_error(parser^, .MissingValue)
			}
			parser_advance(parser)

			parser_white(parser)
			if peek := parser_peek(parser^).type; peek == .Newline || peek == .EOF {
				parser_advance(parser)
			} else {
				return parser_error(parser^, .MissingNewline)
			}

			append(&parser.expr, Keyval{name, value})
		case:
			return parser_error(parser^, .MissingKey)
		}
	}

	return nil
}

@(private = "file")
parser_error :: proc(parser: Parser, error_type: ErrorType) -> Error {
	i := parser_is_end(parser) ? parser.start : parser.current
	line, col := get_line_col(parser.source, parser.tokens[i].span.lo)
	return {line, col - 1, error_type}
}

@(private = "file")
parser_white :: proc(parser: ^Parser) {
	if parser_peek(parser^).type == .White {
		parser_advance(parser)
	}
}

@(private = "file")
parser_expect :: proc(parser: ^Parser, token_type: TokenType) -> Maybe(Error) {
	if token := parser_advance(parser); token_type != token.type {
		error_type: ErrorType = .UnknownError

		#partial switch token_type {
		case .Newline:
			error_type = .MissingNewline
		case .Equals:
			error_type = .MissingEquals
		}

		return parser_error(parser^, error_type)
	}

	return nil
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
