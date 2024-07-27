extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$anim.play("Active")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		$anim.play("Destroyed")
		player_data.currency += 1
		await $anim.animation_finished
		queue_free()
