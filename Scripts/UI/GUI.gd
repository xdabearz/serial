extends CanvasLayer

const HEALTH_ROW_SIZE = 8
const HEALTH_OFFSET = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in player_data.health:
		var new_life = Sprite2D.new()
		new_life.texture = $player_health.texture
		new_life.hframes = $player_health.hframes
		$player_health.add_child(new_life)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$player_currency_number.text = var_to_str(player_data.currency)
	display_life()

func display_life():
	for health in $player_health.get_children():
		var index = health.get_index()
		var x = (index % HEALTH_ROW_SIZE) * HEALTH_OFFSET
		var y = (index / HEALTH_ROW_SIZE) * HEALTH_OFFSET
		health.position = Vector2(x, y)
		
		var last_health = floor(player_data.health)
		if index > last_health:
			health.frame = 0
		if index == last_health:
			health.frame = (player_data.health - last_health) * 4
		if index < last_health:
			health.frame = 4
