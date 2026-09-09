extends SceneTree

const MOUNT_COUNT := 4
const HAND_WEAPONS := [
	"res://player/hands/area_attack.tscn",
	"res://player/hands/melee.tscn",
	"res://player/hands/rapid_fire.tscn",
	"res://player/hands/drone_carrier.tscn",
]
const LASER := "res://player/hands/laser.tscn"
const EXPECTED_ACTIONS := [
	&"move_up", &"move_down", &"move_left", &"move_right",
	&"weapon_super_1", &"weapon_super_2", &"weapon_super_3", &"weapon_super_4",
	&"camera_zoom_in", &"camera_zoom_out", &"restart", &"cancel",
]

var _elapsed := 0.0
var _phase := 0
var _failures := 0

var _player: Player
var _laser_player: Player
var _weapons: Array[BaseWeapon] = []
var _laser: BaseWeapon
var _target: Enemy
var _toucher: Enemy
var _ray_toggles := 0
var _ray_was_visible := false

func _check(label: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_failures += 1
	print(("PASS  " if ok else "FAIL  ") + label + ("" if detail.is_empty() else "  [" + detail + "]"))

func _make_player(at: Vector2) -> Player:
	var player := (load("res://player/player.tscn") as PackedScene).instantiate() as Player
	player.total_health = 100
	root.add_child(player)
	player.global_position = at
	return player

func _make_enemy(at: Vector2, health: int, damage: int) -> Enemy:
	var enemy := (load("res://enemy/enemy.tscn") as PackedScene).instantiate() as Enemy
	enemy.total_health = health
	enemy.damage = damage
	enemy.speed = 0.0
	root.add_child(enemy)
	enemy.global_position = at
	return enemy

func _attach(player: Player, path: String) -> BaseWeapon:
	var weapon := (load(path) as PackedScene).instantiate() as BaseWeapon
	root.add_child(weapon)
	_check("attach " + weapon.name, player.add_weapon(weapon))
	return weapon

func _initialize() -> void:
	_phase_input_map()
	_phase_pause()
	_player = _make_player(Vector2.ZERO)
	_laser_player = _make_player(Vector2(5000, 0))

func _phase_input_map() -> void:
	for action in EXPECTED_ACTIONS:
		_check("action %s exists" % action, InputMap.has_action(action))

	var w := InputEventKey.new()
	w.physical_keycode = KEY_W
	_check("W is bound to move_up", InputMap.event_is_action(w, &"move_up"))

	var one := InputEventKey.new()
	one.keycode = KEY_1
	_check("1 is bound to weapon_super_1", InputMap.event_is_action(one, &"weapon_super_1"))

	_check("BaseWeapon maps every mount to an action",
		BaseWeapon.SUPER_ACTIONS.size() == MOUNT_COUNT)
	for action in BaseWeapon.SUPER_ACTIONS:
		_check("super action %s is registered" % action, InputMap.has_action(action))

func _phase_pause() -> void:
	Pause.release_all()
	_check("tree starts unpaused", not paused and not Pause.is_held())

	Pause.hold(&"a")
	_check("one holder pauses the tree", paused)
	Pause.hold(&"b")
	Pause.release(&"a")
	_check("tree stays paused while another holder remains", paused,
		str(Pause.holders()))
	Pause.release(&"b")
	_check("tree resumes once every holder released", not paused)

	Pause.hold(&"a")
	Pause.hold(&"b")
	Pause.release_all()
	_check("release_all clears every holder",
		not paused and not Pause.is_held())
	_check("Engine.time_scale is left alone", is_equal_approx(Engine.time_scale, 1.0),
		"time_scale=%.2f" % Engine.time_scale)

func _process(delta: float) -> bool:
	_elapsed += delta

	match _phase:
		0:
			_phase_attach()
		1:
			if _elapsed > 0.1:
				_phase_wiring()
		2:
			if _elapsed > 1.5:
				_phase_combat()
		3:
			_track_ray()
			if _elapsed > 3.0:
				_phase_super_end()
				_phase_ui()
				return _finish()
	return false

func _finish() -> bool:
	print("")
	print("smoke test: %d failure(s)" % _failures)
	quit(1 if _failures > 0 else 0)
	return true

func _phase_attach() -> void:
	var indices: Array[int] = []
	for path in HAND_WEAPONS:
		var weapon := _attach(_player, path)
		_weapons.append(weapon)
		indices.append(weapon.index)
		_check(weapon.name + " active on attach", weapon._is_active)

	_check("mounts assigned uniquely", indices.size() == MOUNT_COUNT, str(indices))

	var overflow := (load(HAND_WEAPONS[0]) as PackedScene).instantiate() as BaseWeapon
	root.add_child(overflow)
	_check("5th weapon rejected, not slotted twice", not _player.add_weapon(overflow))
	overflow.queue_free()

	_laser = _attach(_laser_player, LASER)

	_target = _make_enemy(Vector2(10, 0), 100, 0)
	_toucher = _make_enemy(Vector2.ZERO, 1000, 3)
	_phase = 1

func _phase_wiring() -> void:
	var area := _weapons[0].get_node("AreaAttackCollider") as Area2D
	_check("weapon hitbox on player_weapon layer",
		area.collision_layer == Combat.LAYER_PLAYER_WEAPON)
	_check("weapon hitbox masks enemy only",
		area.collision_mask == Combat.LAYER_ENEMY)

	var player_collider := _player.get_node("PlayerCollider") as Area2D
	_check("player on player layer", player_collider.collision_layer == Combat.LAYER_PLAYER)
	_check("weapon hitbox ignores the player",
		not area.get_overlapping_areas().has(player_collider))

	_check("Combat.enemy_of finds the enemy",
		Combat.enemy_of(_target.get_node("EnemyCollider") as Area2D) == _target)
	_check("Combat.player_of finds the player",
		Combat.player_of(player_collider) == _player)
	_check("Combat.enemy_of rejects a non-enemy", Combat.enemy_of(player_collider) == null)

	_check("area_attack has no super", not _weapons[0].has_super)
	for weapon in _weapons.slice(1):
		_check(weapon.name + " declares a super", weapon.has_super)
	_phase = 2

func _phase_stun() -> void:
	var dummy := _make_enemy(Vector2(-4000, 2000), 10, 0)
	dummy.speed = 100.0
	dummy.player = _laser_player
	_check("enemy starts unstunned", not dummy.is_stunned())

	var start := dummy.global_position
	dummy._process(0.1)
	_check("an unstunned enemy chases the player", dummy.global_position != start)

	dummy.apply_stun(0.5)
	_check("apply_stun stuns the enemy", dummy.is_stunned())

	var held := dummy.global_position
	dummy._process(0.1)
	_check("a stunned enemy does not move", dummy.global_position == held)

	dummy.apply_stun(0.1)
	_check("a shorter stun does not cut the running one short", dummy.is_stunned())

	dummy._process(0.5)
	_check("stun expires after its duration", not dummy.is_stunned())

	var resumed := dummy.global_position
	dummy._process(0.1)
	_check("the enemy moves again once the stun expires",
		dummy.global_position != resumed)

	dummy.apply_stun(0.0)
	_check("a zero-second stun is ignored", not dummy.is_stunned())
	dummy.queue_free()

	var melee: Variant = _weapons[1]
	_check("melee configures a super stun length", melee.super_stun_length > 0.0,
		"length=%.2f" % melee.super_stun_length)

	var plain := _make_enemy(Vector2(-4000, 2500), 100, 0)
	melee._start_attack()
	melee._on_area_entered(plain.get_node("EnemyCollider") as Area2D)
	_check("a normal melee hit damages without stunning",
		plain.received_damage > 0 and not plain.is_stunned())
	melee._end_attack()
	plain.queue_free()

	var stunned := _make_enemy(Vector2(-4000, 3000), 100, 0)
	melee._start_super()
	melee._on_area_entered(stunned.get_node("EnemyCollider") as Area2D)
	_check("melee super stuns the enemy it hits", stunned.is_stunned())
	_check("melee super still damages the enemy it hits", stunned.received_damage > 0,
		"damage=%d" % stunned.received_damage)
	melee._end_super()
	_check("the stun outlives the super", stunned.is_stunned())
	stunned.queue_free()

func _phase_combat() -> void:
	_phase_stun()
	_check("weapon damaged the enemy", _target.received_damage > 0,
		"damage=%d" % _target.received_damage)
	_check("enemy contact damaged the player", _player.received_damage > 0,
		"health=%d" % _player.current_health())

	_player.shield = 10
	var health_before := _player.current_health()
	_player.receive_damage(4)
	_check("shield absorbs damage", _player.shield == 6 and _player.current_health() == health_before,
		"shield=%d" % _player.shield)
	_player.shield = 0

	var bullets := root.get_children().filter(func(n): return n is Bullet)
	_check("rapid_fire spawned bullets", bullets.size() > 0, "count=%d" % bullets.size())
	_check("bullets fall back to the root when no container exists",
		bullets.all(func(b): return b.get_parent() == root))

	var death_seen := [false]
	_player.died.connect(func(): death_seen[0] = true)
	_player.receive_damage(_player.current_health())
	_check("player emits died exactly once at zero health",
		death_seen[0] and _player.is_dead())
	death_seen[0] = false
	_player.receive_damage(5)
	_check("further damage after death is ignored", not death_seen[0])

	for weapon in _weapons + [_laser]:
		if not weapon.has_super:
			continue
		weapon._start_super()
		_check(weapon.name + " super started", weapon.is_in_super)
	_phase = 3

func _phase_ui() -> void:
	Pause.release_all()

	var selector := (load("res://ui/item_selector_ui.tscn") as PackedScene).instantiate() as ItemSelector
	root.add_child(selector)
	_check("selector keeps its container export wired", selector.container != null)
	_check("selector survives a pause", selector.process_mode == Node.PROCESS_MODE_ALWAYS)

	var chosen: Array[String] = []
	var cancelled := [false]
	_check("show_choice accepts a choice list",
		selector.show_choice(["Alpha", "Beta"], func(c): chosen.append(c),
			func(): cancelled[0] = true))
	_check("showing a choice pauses the tree", paused)
	_check("a second overlapping pickup is refused",
		not selector.show_choice(["Gamma"], func(_c): pass, func(): pass))
	_check("one button per choice plus Cancel", selector.container.get_child_count() == 3,
		"children=%d" % selector.container.get_child_count())
	_check("choice buttons still process while paused",
		selector.container.get_children().all(func(b): return b.can_process()))

	(selector.container.get_child(0) as Button).pressed.emit()
	_check("choosing invokes the success callback",
		chosen.size() == 1 and chosen[0] == "Alpha", str(chosen))
	_check("choosing unpauses and clears the buttons",
		not paused and selector.container.get_child_count() == 0)
	_check("cancel callback was not fired", not cancelled[0])

	# Death while a choice is open must leave the game paused.
	var victim := _make_player(Vector2(9000, 0))
	var death_ui := (load("res://ui/death_ui.tscn") as PackedScene).instantiate() as DeathUI
	death_ui.player = victim
	root.add_child(death_ui)
	_check("death ui starts hidden", not death_ui.visible)

	selector.show_choice(["Alpha"], func(_c): pass, func(): pass)
	victim.receive_damage(victim.total_health)
	_check("death shows the death ui", death_ui.visible)
	_check("both holders are active", Pause.holders().size() == 2, str(Pause.holders()))

	selector._on_cancelled(func(): pass)
	_check("closing the selector leaves the game paused for death", paused,
		str(Pause.holders()))

	Pause.release_all()
	_check("release_all resumes after everything", not paused)
	selector.queue_free()
	death_ui.queue_free()
	victim.queue_free()

func _track_ray() -> void:
	var visible_now := (_laser.get_node("Ray") as Node2D).visible
	if visible_now != _ray_was_visible:
		_ray_toggles += 1
		_ray_was_visible = visible_now

func _phase_super_end() -> void:
	_check("laser pulses on and off", _ray_toggles >= 2, "toggles=%d" % _ray_toggles)
	for weapon in _weapons + [_laser]:
		if not weapon.has_super:
			continue
		_check(weapon.name + " super ended", not weapon.is_in_super,
			"progress=%.2f" % weapon.super_progress())

	var overpenetrating := root.get_children().filter(
		func(n): return n is Bullet and n.overpenetration)
	_check("rapid_fire super released a charged bullet", overpenetrating.size() > 0)
