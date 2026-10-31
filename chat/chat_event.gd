@abstract class_name AltStreamChatEvent

enum Role {
	BROADCASTER = 1,
	MODERATOR = 2,
	SUBSCRIBER = 4,
	SUPPORTER = 8,
}

@abstract class UserAuthoredEvent:
	extends AltStreamChatEvent

	var author_username: String
	var author_image: String
	var author_pronouns: String
	var user_color: Color
	var color: Color
	var is_broadcaster: bool
	var is_moderator: bool
	var badges: Array[String]

	func _init(event_data: Variant):
		super(event_data)

		author_username = event_data.get("authorUsername")
		author_image = event_data.get("authorImage")
		author_pronouns = event_data.get("authorPronouns")
		user_color = Color(event_data.get("userColor"))
		color = Color(event_data.get("color"))
		is_broadcaster = event_data.get("isBroadcaster") == true
		is_moderator = event_data.get("isModerator") == true
		if "badges" in event_data:
			badges.assign(event_data.get("badges"))


class MessageEvent:
	extends UserAuthoredEvent

	func _init(event_data: Variant):
		super(event_data)


class StickerEvent:
	extends MessageEvent

	var sticker_name: String
	var sticker_url: String

	func _init(event_data: Variant):
		super(event_data)

		sticker_name = event_data.get("stickerName")
		sticker_url = event_data.get("stickerUrl")


class RedemptionEvent:
	extends UserAuthoredEvent

	var from: String
	var username: String
	var reward_name: String
	var cost: int
	var points_name: String
	var user_input: Variant  # Null or string

	func _init(event_data: Variant):
		super(event_data)

		if "data" in event_data:
			from = event_data.data.get("from")
			username = event_data.data.get("username")
			reward_name = event_data.data.get("rewardName")
			cost = event_data.data.get("cost")
			points_name = event_data.data.get("pointsName")
			user_input = event_data.data.get("userInput")


var type: String
var id: String
var author: String
var text: String
var sent_at: int
var channel: String
var roles: int
var source: String

var _event_data: Variant


func _init(event_data: Variant):
	_event_data = event_data

	type = event_data.get("type")
	id = event_data.get("id")
	author = event_data.get("author")
	text = event_data.get("text")
	sent_at = event_data.get("sentAt")
	channel = event_data.get("channel")
	if "source" in event_data:
		source = event_data.get("source")

	roles = 0
	var role_data = event_data.get("roles")
	if role_data != null:
		if role_data.get("broadcaster"):
			roles |= Role.BROADCASTER
		if role_data.get("moderator"):
			roles |= Role.MODERATOR
		if role_data.get("subscriber"):
			roles |= Role.SUBSCRIBER
		if role_data.get("supporter"):
			roles |= Role.SUPPORTER


static func from_json(event_data: Variant) -> AltStreamChatEvent:
	var event_type = event_data.get("type")
	match event_type:
		"message":
			if "stickerUrl" in event_data:
				return StickerEvent.new(event_data)

			return MessageEvent.new(event_data)

		"redemption":
			return RedemptionEvent.new(event_data)

	push_warning('Unsupported chat event type: "%s"' % event_type)

	return null
