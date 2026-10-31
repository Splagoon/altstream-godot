# AltStream-Godot

A GDScript wrapper for the [AltStream API](https://altstream.online). Currently only supports chat messages and redeems, with more to come in the future.

Uses [godot-http-event-source](https://gitlab.com/DaGammla/godot-http-event-source) (included) to connect to the chat stream.

## Example

```gdscript
extends Node

var altstream_chat_client: AltStreamChatClient


func _ready() -> void:
    altstream_chat_client = AltStreamChatClient.new()
    alstream_chat_client.chat_event.connect(_on_altstream_chat_event)
    var err := altstream_chat_client.connect_to_channel("splagoon")
    assert(err == OK)


func _process(_delta) -> void:
    altstream_chat_client.poll()


func _on_altstream_chat_event(chat_event: AltStreamChatEvent) -> void:
    if chat_event is AltStreamChatEvent.StickerEvent:
        # Someone sent a sticker
        print("%s sent a sticker: %s" % [chat_event.author, chat_event.sticker_name])
    elif chat_event is AltStreamChatEvent.MessageEvent:
        # Someone sent a message
        print("%s sent a message: %s" % [chat_event.author, chat_event.text])
    elif chat_event is AltStreamChatEvent.RedemptionEvent:
        # Someone redemeed a reward
        print("%s redeemed: %s" % [chat_event.author, chat_event.reward_name])
```
