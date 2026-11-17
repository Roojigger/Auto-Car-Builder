class_name Orientation

static var _table: Array[Basis] = []

static func table() -> Array[Basis]:
	if _table.is_empty():
		var axes := [Vector3.RIGHT, Vector3.UP, Vector3.BACK]
		var perms := [[0,1,2],[0,2,1],[1,0,2],[1,2,0],[2,0,1],[2,1,0]]
		for p in perms:
			for sx in [1, -1]:
				for sy in [1, -1]:
					for sz in [1, -1]:
						var b := Basis(axes[p[0]] * sx, axes[p[1]] * sy, axes[p[2]] * sz)
						if is_equal_approx(b.determinant(), 1.0):
							_table.append(b)
	return _table

static func to_basis(index: int) -> Basis:
	return table()[index]

static func rotated(index: int, axis: Vector3i, reverse: bool) -> int:
	var t := table()
	var r := Basis(axis, (-1 if reverse else 1) * PI * 0.5) * t[index]
	for i in t.size():
		if t[i].is_equal_approx(r):
			return i
	push_error("No matching orientation")
	return index
