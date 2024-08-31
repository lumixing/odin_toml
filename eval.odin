package toml

import "core:reflect"

Tree :: distinct map[string]Value

eval :: proc(expr: []Expr) -> Tree {
	tree: Tree

	for ex in expr {
		switch e in ex {
		case Keyval:
			tree[e.key] = e.value
		}
	}

	return tree
}

get :: proc(tree: Tree, key: string, $T: typeid) -> (T, bool) {
	if value, ok := tree[key]; ok {
		if value_t, ok := value.(T); ok {
			return value_t, true
		} else {
			return {}, false
		}
	} else {
		return {}, false
	}
}
