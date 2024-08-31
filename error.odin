package toml

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
