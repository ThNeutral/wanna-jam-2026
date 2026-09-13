class_name Combat
extends Object

const LAYER_PLAYER := 1
const LAYER_ENEMY := 2
const LAYER_PLAYER_WEAPON := 4
const LAYER_PICKUP := 8

static func enemy_of(area: Area2D) -> Enemy:
	return area.get_parent() as Enemy

static func player_of(area: Area2D) -> Player:
	return area.get_parent() as Player
