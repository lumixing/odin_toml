package toml

@(private)
Expr :: union {
	Keyval,
}

@(private)
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
