extends Node

const WORLD: int = 1
const CAT: int = 2
const ENEMY: int = 3
const PLATFORM: int = 4

# Convert a list of layer numbers to a collision bitmask
static func to_mask(layer_numbers: Array) -> int:
	var m := 0
	for n in layer_numbers:
		m |= (1 << (n - 1))
	return m
