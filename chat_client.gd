class_name AltStreamChatClient

signal chat_event(event: AltStreamChatEvent)

const CHAT_ENDPOINT := "https://altstream.online/api/chat/stream?channel=%s"

var _http_event_source: HTTPEventSource
var _is_connected := false


func connect_to_channel(channel: String) -> Error:
	_http_event_source = HTTPEventSource.new()
	_http_event_source.event.connect(_on_event)
	var err = _http_event_source.connect_to_url(CHAT_ENDPOINT % channel.uri_encode())
	if err == OK:
		_is_connected = true
	return err


func poll() -> void:
	_http_event_source.poll()


func _on_event(event: ServerSentEvent) -> void:
	var json := JSON.new()
	var err := json.parse(event.data)
	if err != OK:
		push_error("Error parsing SSE body: %s" % json.get_error_message())
		return

	if typeof(json.data) != TYPE_ARRAY:
		push_warning("Error parsing SSE body: expected an array, got something else")
		return

	for event_data in json.data:
		var parsed_chat_event = AltStreamChatEvent.from_json(event_data)
		if parsed_chat_event != null:
			chat_event.emit(parsed_chat_event)
