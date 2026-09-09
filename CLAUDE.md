# WANNA-JAM

Top-down survivor-like in **Godot 4.7**. The player is a chassis with four weapon mounts;
weapons are picked up off the map and slotted into a mount, each with a keyed "super".

## Verify your work

The engine binary is in the repo root (gitignored) and is the only source of truth.
**Run all three checks before reporting a change as done.**

The smoke test is the one that actually exercises gameplay — weapon slotting, collision
wiring, damage, and every super's start/end. Run it after touching anything under
`player/`, `enemy/`, or `combat.gd`. It prints `PASS`/`FAIL` per check and exits
non-zero on failure:

```bash
./Godot_v4.7.2-stable_win64_console.exe --headless --script tools/smoke_test.gd
```

Extend it when you add a weapon or a combat rule. It is a `SceneTree` script driving
real frames, so it catches things static analysis cannot — it is how the charging-bullet
bug below was found.

Parse-check one script:

```bash
./Godot_v4.7.2-stable_win64_console.exe --headless --check-only --script player/hands/melee.gd
```

Parse-check everything, then boot the game headless for a few seconds:

```bash
for f in $(find . -name '*.gd'); do ./Godot_v4.7.2-stable_win64_console.exe --headless --check-only --script "$f"; done; ./Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 120
```

**After adding or renaming a `class_name`, re-scan the project first:**

```bash
./Godot_v4.7.2-stable_win64_console.exe --headless --import
```

Global classes live in `.godot/global_script_class_cache.cfg`, which is gitignored and
only rebuilt on import. Skip this and every script that references the new type fails
with `Identifier "Foo" not declared in the current scope` — a stale cache, not a real
error in your code. The import takes about 15 seconds.

All three must be silent — no `SCRIPT ERROR`, no `Parse Error`, and the smoke test
exiting 0. A clean boot takes about 3 seconds and a full import about 15; if either
suddenly takes minutes, something is generating error spam per loaded resource.

Two things the CLI will _not_ tell you:

- **GDScript warnings never reach stdout.** Neither `--check-only` nor `--editor --quit`
  prints them; they only appear in the editor's Script panel. So unused variables,
  base-class shadowing and narrowing conversions will pass every command above. The
  rules under _GDScript rules_ are on you to apply, not the toolchain.
- Headless boot covers scene loading, `_ready`, and enemy spawning; it never picks up a
  weapon or opens a menu. That gap is what `tools/smoke_test.gd` exists to fill.

Never claim a gameplay change "looks right" — you cannot see the screen. Say what you
verified (parses, boots, smoke test) and what you did not (anything visual, and
anything driven by real mouse or key input, which headless never supplies).

## Layout

| Path                  | Role                                                                    |
| --------------------- | ----------------------------------------------------------------------- |
| `root.tscn`           | Main scene. Wires spawners and UI to `Player` via exported `NodePath`s. |
| `combat.gd`           | `Combat` — collision layer constants + area→entity lookups.             |
| `pause.gd`            | `Pause` — reference-counted `SceneTree.paused` owner.                   |
| `base_weapon.gd`      | `BaseWeapon` — weapon lifecycle and the shared super state machine.     |
| `player/`             | `Player`, and every weapon under `player/hands/`.                       |
| `enemy/`              | `Enemy` and its spawner.                                                |
| `pickups/`            | Map pickups (`HandPickup`) and their placement (`hand_spawner.gd`).     |
| `ui/`                 | `DeathUI`, `ItemSelector`.                                              |
| `background/`         | TileMap scene and tilesets.                                             |
| `tools/smoke_test.gd` | Headless gameplay smoke test.                                           |

## Collision layers

Physics does the filtering. Layers are named in `project.godot`:

| Bit | Value | Layer           | Used by                      |
| --- | ----- | --------------- | ---------------------------- |
| 1   | 1     | `player`        | `PlayerCollider`             |
| 2   | 2     | `enemy`         | `EnemyCollider`              |
| 3   | 4     | `player_weapon` | every weapon hitbox, bullets |
| 4   | 8     | `pickup`        | `HandPickup/Area2D`          |

Never filter contacts by comparing `area.name` to a string. Set `collision_layer` /
`collision_mask` on the `Area2D` in the scene, then resolve the entity through
`Combat`:

```gdscript
func _on_area_entered(area: Area2D) -> void:
	var enemy := Combat.enemy_of(area)
	if enemy != null:
		enemy.receive_damage(damage)
```

`Combat.enemy_of` / `player_of` assume the `Area2D` is a **direct child** of the entity
node. If you nest a hitbox deeper, extend `combat.gd` rather than reaching for
`get_parent().get_parent()` at the call site.

## Input

Everything goes through the `InputMap` in `project.godot` — never
`Input.is_key_pressed(KEY_W)`.

| Action                                               | Bound to                   |
| ---------------------------------------------------- | -------------------------- |
| `move_up` / `move_down` / `move_left` / `move_right` | WASD (physical) + arrows   |
| `weapon_super_1` … `_4`                              | `1`–`4` and numpad `1`–`4` |
| `camera_zoom_in` / `camera_zoom_out`                 | mouse wheel up / down      |
| `restart`                                            | `R`                        |
| `cancel`                                             | `Escape`                   |

Read movement with `Input.get_vector(...)`, which clamps the result to length 1 — summing
four unit vectors by hand is what made diagonal movement 41% faster than orthogonal.
`BaseWeapon.SUPER_ACTIONS[index]` maps a mount to its super action, so mount count and
action count must stay in step (the smoke test asserts this).

To add or rebind an action, do not hand-write the `Object(InputEventKey, ...)` blob.
Write a throwaway `SceneTree` script that calls
`ProjectSettings.set_setting("input/<name>", {"deadzone": …, "events": [...]})` then
`ProjectSettings.save()`, run it with `--headless --script`, and delete it. Godot then
serialises the events correctly for its own version.

## Pausing

`Pause` owns `SceneTree.paused` and reference-counts holders by name:

```gdscript
Pause.hold(&"item_selector")     # pauses
Pause.release(&"item_selector")  # resumes only if no other holder remains
Pause.release_all()              # on restart
```

**Never touch `Engine.time_scale`.** Two screens used to each write it directly, so
closing the item selector while dead resumed a game the player had already lost.

Any UI that must work while paused needs `process_mode = 3`
(`PROCESS_MODE_ALWAYS`) on its root node in the scene — `DeathUI` and `ItemSelection`
both set it. Runtime-created children inherit it.

Death is a signal, not a poll: `Player` emits `died` once when health reaches zero, and
`receive_damage` ignores further hits after that. Do not add `_process` polling of
`is_dead()`.

## Adding a weapon

1. `extends BaseWeapon`, one scene + one script under `player/hands/`.
2. Give every hitbox `collision_layer = 4`, `collision_mask = 2`.
3. Add the scene to `HandSpawner.weapons` in `root.tscn`.

`BaseWeapon` owns `_process`. **Override `_update(delta)`, never `_process`** — a
subclass `_process` that forgets `super._process(delta)` silently kills that weapon's
super, which is exactly how the old `area_attack` bug happened. `_physics_process` is
free to override; `BaseWeapon` does not use it.

Lifecycle:

- `on_added()` — the weapon is already reparented to its mount with `position`,
  `rotation` and `index` set. Call `set_is_active(true)`. Only override when you need
  extra setup, and call `set_is_active(true)` yourself when you do.
- `set_is_active(new_value)` — override to react (show/hide parts, `queue_redraw()`);
  always assign `_is_active`.

Supers are entirely `BaseWeapon`'s: it watches the slot key (`1`–`4` via `index`),
respects `super_cooldown`, then runs for `super_length` seconds. Implement
`_on_super_started()` / `_on_super_ended()` and read `is_in_super` /
`super_progress()` (0→1 ramp). Do not add per-weapon `is_in_super` flags or duration
counters — that duplication is what left the melee super permanently stuck on.

A weapon with no super sets `has_super = false` in its scene.

## GDScript rules

Tabs, not spaces. Prefer `:=` and annotate every parameter and return type — the
inference is what catches these mistakes.

**Never let a name shadow a base-class member.** `Node` already has `name`, `scale`,
`position`, `rotation`, `owner`. `func _scale_ray(scale: float)` and
`var name = weapon.name` both silently shadowed real properties here. Name the
parameter for its role (`factor`, `choice`, `amount`).

**Never `while` on an exported interval** without guarding it — a designer typing `0`
into `attack_interval` hangs the editor:

```gdscript
if attack_interval <= 0.0:
	return

_counter += delta
while _counter > attack_interval:
	_counter -= attack_interval
	_attack()
```

**`assert` is stripped in release builds.** It documents a contract; it does not
enforce one. Anything that must hold at runtime needs a real branch. Returning a
`bool` and letting the caller decide beat asserting — `Player.add_weapon` does this,
and the old assert-only version indexed `handles[-1]` in release, overwriting an
occupied mount.

**Keep `_draw()` pure.** Draw and nothing else. `area_attack` used to write a physics
shape radius from inside `_draw`.

**`clamp(value, min, max)`** — value first. `hand.gd` had it backwards and the clamp
never did anything.

**A freed object is not `null`.** `queue_free()` leaves your reference pointing at a
`<Freed Object>`; `obj == null` is still `false` and the next member access fails. Guard
with `is_instance_valid(obj)`. The charged-shot bug was exactly this: an
`if _super_bullet == null: return` guard that never fired.

**A projectile is armed the moment it enters the tree.** Its `Area2D` starts monitoring
before you have assigned `damage`, `direction` or `overpenetration`, so it can hit
something with default values and — since `overpenetration` defaults to `false` —
`queue_free()` itself. `Bullet.set_armed(false)` on spawn, `set_armed(true)` once
`_release_bullet` has filled everything in. Anything that lives in the tree while being
"charged up" needs the same treatment.

Other traps this codebase hit:

- `PackedScene.instantiate()` and `Node.duplicate()` **share sub-resources** by
  default. Mutating a `Shape2D` from a script affects every instance — `duplicate()`
  the resource first, as `area_attack.gd` does in `_ready`.
- GDScript arrays accept negative indices. An unchecked `-1` from a "not found" lookup
  reads the last element instead of failing.
- Instantiate only once you are committed to `add_child`. A retry loop that builds the
  node up front leaks it on every failed attempt.
- `add_child` before assigning `global_position`; on an orphan node it is just
  `position`.
- Prefer `push_warning` over a bare `assert` for recoverable content problems, so the
  message survives into a release build.

## Known debt

- **Passives are unimplemented.** The `Multiparts` slots still exist in `player.tscn`,
  but `Player.add_passive` and its slot lookup were removed — they were unreferenced and
  there is no `Passive` type. Rebuild the contract alongside the first real passive
  rather than restoring the old scaffolding from git history.
- **No projectile pooling.** Bullets are instantiated per shot and parented to the
  `Projectiles` node (group `projectiles`), so they die with the scene instead of piling
  up on the window root. They still only despawn at
  `Bullet.MAXIMUM_TRAVEL_DISTANCE` (10000 units — about 33 seconds at the current bullet
  speed), which is far outside the ~1000-unit playfield. Lowering it or pooling is a
  tuning call.
- **`root.tscn` still holds two scratch nodes**: a `Reference` placeholder sprite and a
  hand-placed `Enemy`. They look like layout aids rather than content; left in place
  because deleting scene content is the author's call.
- **`EnemySpawner.spawn_radius` is set to 250** so enemies stop stacking on a single
  point. It is a number picked to be obviously better than zero, not a tuned one.
- **`DroneCarrier.shield_size` is set to 3** against a 5-health player. Same caveat.
