extends Node3D

@export var music = "Ti5or - Bg"

func _process(delta: float) -> void:
	$Label3D.text = "Song: " + music + "\nCurently playing: " + Music.curentMusic

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body.is_in_group("Player"):
		Music.nextMusic = music
