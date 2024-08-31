package toml

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:time"
import "core:unicode"

@(private)
Lexer :: struct {
	source:  []byte,
	tokens:  [dynamic]Token,
	start:   int,
	current: int,
}

@(private)
lexer_scan :: proc(lexer: ^Lexer) -> Maybe(Error) {
	for !lexer_is_end(lexer^) {
		lexer.start = lexer.current
		char := lexer_advance(lexer)

		switch char {
		case ' ', '\t':
			for lexer_peek(lexer^) == ' ' || lexer_peek(lexer^) == '\t' {
				lexer_advance(lexer)
			}
			lexer_add_token(lexer, .White)
		case '\r':
			if lexer_peek(lexer^) != '\n' {
				return lexer_error(lexer^, .InvalidReturn)
			}
		case '\n':
			lexer_add_token(lexer, .Newline)
		case '=':
			lexer_add_token(lexer, .Equals)
		case '"':
			builder := new(strings.Builder)
			strings.builder_init(builder)
			terminated := true

			for lexer_peek(lexer^) != '"' {
				peek, ok := lexer_peek(lexer^)
				if peek == '\r' || peek == '\n' || !ok {
					terminated = false
					break
				}

				if peek == '\\' {
					lexer_advance(lexer)
					switch peek := lexer_advance(lexer); peek {
					case 'n':
						strings.write_rune(builder, '\n')
					case 'r':
						strings.write_rune(builder, '\r')
					case 't':
						strings.write_rune(builder, '\t')
					case '\\':
						strings.write_rune(builder, '\\')
					case '"':
						strings.write_rune(builder, '"')
					case:
						return lexer_error(lexer^, .InvalidEscape)
					}
				} else {
					strings.write_rune(builder, peek)
					lexer_advance(lexer)
				}
			}

			lexer_advance(lexer)

			if !terminated {
				return lexer_error(lexer^, .UnterminatedString)
			}

			lexer_add_token(lexer, .String, strings.to_string(builder^))
		case '\'':
			terminated := true

			for lexer_peek(lexer^) != '\'' {
				peek, ok := lexer_peek(lexer^)
				if peek == '\r' || peek == '\n' || !ok {
					terminated = false
					break
				}

				lexer_advance(lexer)
			}

			lexer_advance(lexer)

			if !terminated {
				return lexer_error(lexer^, .UnterminatedString)
			}

			lexer_add_token(lexer, .String, lexer_span_as_string(lexer^, 1, 1))
		case '#':
			for lexer_peek(lexer^) != '\r' && lexer_peek(lexer^) != '\n' && !lexer_is_end(lexer^) {
				lexer_advance(lexer)
			}
		case:
			if is_name(char) {
				for is_name(lexer_peek(lexer^)) {
					lexer_advance(lexer)
				}

				switch str := lexer_span_as_string(lexer^); str {
				case "true":
					lexer_add_token(lexer, .Bool, true)
				case "false":
					lexer_add_token(lexer, .Bool, false)
				case:
					lexer_add_token(lexer, .Ident, str)
				}
			} else {
				return lexer_error(lexer^, .InvalidCharacter)
			}
		}
	}

	lexer_add_token(lexer, .EOF)
	return nil
}

@(private = "file")
lexer_error :: proc(lexer: Lexer, error_type: ErrorType) -> Error {
	i := lexer_is_end(lexer) ? lexer.start : lexer.current
	line, col := get_line_col(lexer.source, i)
	return {line, col - 1, error_type}
}

@(private = "file")
lexer_peek :: proc(lexer: Lexer) -> (rune, bool) #optional_ok {
	if lexer_is_end(lexer) {
		return 0, false
	}

	return rune(lexer.source[lexer.current]), true
}

@(private = "file")
lexer_advance :: proc(lexer: ^Lexer) -> (rune, bool) #optional_ok {
	defer lexer.current += 1
	return lexer_peek(lexer^)
}

@(private = "file")
lexer_is_end :: proc(lexer: Lexer) -> bool {
	return lexer.current >= len(lexer.source)
}

@(private = "file")
lexer_add_token :: proc(lexer: ^Lexer, type: TokenType, value: TokenValue = nil) {
	span := Span{lexer.start, lexer.current}
	append(&lexer.tokens, Token{type, value, span})
}

@(private = "file")
lexer_span_as_string :: proc(lexer: Lexer, start_trim := 0, end_trim := 0) -> string {
	return string(lexer.source[lexer.start + start_trim:lexer.current - end_trim])
}

@(private = "file")
is_alpha :: proc(char: rune) -> bool {
	return (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
}

@(private = "file")
is_digit :: proc(char: rune) -> bool {
	return char >= '0' && char <= '9'
}

@(private = "file")
is_name :: proc(char: rune) -> bool {
	return is_alpha(char) || is_digit(char) || char == '-' || char == '_'
}
