package toml

import "core:time"

Token :: struct {
	type:  TokenType,
	value: TokenValue,
	span:  Span,
}

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

TokenValue :: union {
	string,
	i64,
	f64,
	bool,
	time.Time,
}

Span :: struct {
	lo, hi: int,
}
