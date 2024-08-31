package toml

import "core:time"

@(private)
Token :: struct {
	type:  TokenType,
	value: TokenValue,
	span:  Span,
}

@(private)
TokenType :: enum {
	EOF,
	White,
	Newline,
	Equals,
	Dot,
	Ident,
	String,
	Integer,
	Float,
	Bool,
	Time,
}

@(private)
TokenValue :: union {
	string,
	i64,
	f64,
	bool,
	time.Time,
}

@(private)
Span :: struct {
	lo, hi: int,
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
