@abstract
class_name TypingMinigameVariant
extends Control

@warning_ignore("unused_signal") # die stupid warning
signal minigame_variant_finished

## Override this.
@abstract func start_minigame_variant(customer: Customer) -> void
