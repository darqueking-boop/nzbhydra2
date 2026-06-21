extends Node2D
class_name DamageNumber

## Floating damage/heal number that pops up and fades out.

static func spawn(parent: Node, world_pos: Vector2, amount: int, color: Color = Color.WHITE) -> void:
	var label := Label.new()
	label.text = str(amount) if amount > 0 else "Miss"
	label.position = world_pos
	label.z_index = 100
	label.add_theme_font_size_override("font_size", 28)
	label.modulate = color
	parent.add_child(label)

	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", world_pos.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	await tween.finished
	label.queue_free()
