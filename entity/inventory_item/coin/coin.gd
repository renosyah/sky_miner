extends InventoryItem

const coins = [
	preload("res://assets/sounds/coin/coin_1.wav"),
	preload("res://assets/sounds/coin/coin_2.wav"),
	preload("res://assets/sounds/coin/coin_3.wav")
]

func picked_up():
	.picked_up()
	_sound.stream = coins[rand_range(0, coins.size())]
	_sound.play()
	
	
