class_name MessageBus
extends Object

enum EventType {
	PICKED_PASSIVE,
	PLAYER_DIED,
	PICKED_WEAPON
}

static var _callbacks: Dictionary[EventType, Array] = {
	EventType.PICKED_PASSIVE: [],
	EventType.PLAYER_DIED: [],
	EventType.PICKED_WEAPON: []
}

static func publish(event_type: EventType, message: BaseMessage) -> void:
	for callback in _callbacks[event_type]:
		(callback as Callable).call(message)

static func subscribe(event_type: EventType, callable: Callable) -> void:
	_callbacks[event_type].append(callable)
