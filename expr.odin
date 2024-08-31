package toml

Expr :: union {
	Keyval,
}

Keyval :: struct {
	key:   string,
	value: Value,
}

Value :: union {
	string,
	i64,
	f64,
	bool,
}
