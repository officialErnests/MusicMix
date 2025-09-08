extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var curentMusic = $"Ti5or - Bg"
var nextMusic = null
var fadeout = 0
var fadein = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !curentMusic:
		curentMusic = $"Ti5or - Bg"
	if fadein < 1:
		fadein += delta
		fadein = clamp(fadein,0,1)
		curentMusic.volume_linear = Music.volume * (fadein/1)
		return
	if fadeout > 0:
		fadeout -= delta
		fadeout = clamp(fadeout,0,1)
		curentMusic.volume_linear = Music.volume * (fadeout/1)
		return
	if nextMusic:
		print("YUP")
		curentMusic.stop()
		curentMusic = nextMusic
		nextMusic = null

		curentMusic.volume_linear = 0
		curentMusic.play()
		fadein = 0
		return
	curentMusic.volume_linear = Music.volume
	if !curentMusic.playing:
		curentMusic = $"Ti5or - Bg"
		nextMusic = null

		curentMusic.volume_linear = 0
		curentMusic.play()
		return
	if Music.nextMusic != "" && Music.nextMusic != curentMusic.name:
		if Music.checklist_5EEnoWAY.has(Music.nextMusic): Music.checklist_5EEnoWAY[Music.nextMusic] = true
		nextMusic = get_node(Music.nextMusic)
		Music.curentMusic = Music.nextMusic
		Music.nextMusic = ""
		fadeout = 1
