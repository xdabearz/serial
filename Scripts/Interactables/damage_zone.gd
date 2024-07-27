extends Area2D

@export var current_state: spike_state
enum spike_state {ACTIVE, ANIMATED}

func _process(delta):
	match current_state:
		spike_state.ACTIVE:
			active()
		spike_state.ANIMATED:
			active_animated()
			
func active():
	$anim.play("Active")
	
func active_animated():
	$anim.play("Active_Animated")

func _on_body_entered(body):
	if body.name == "Player":
		player_data.health -= 1

