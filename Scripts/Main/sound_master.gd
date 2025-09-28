extends Node

enum SFX {
	BUBBLES,
	LANDING,
	STEPING,
	JUMPING,
	ATTACKING,
	TELEPORT,
	HURT
}
@export var pitch_scale_min : float = 0.95
@export var pitch_scale_max : float = 1.05

func _ready() -> void:
	$AudioStreamPlayer2D10.play()

# this should all be cached nodes but game jam time crunch momento
func play(sound_to_play: SFX) -> void:
	match sound_to_play:
		SFX.BUBBLES:
			match randi_range(0,2):
				0:
					$AudioStreamPlayer2D.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
					$AudioStreamPlayer2D.play()
				1:
					$AudioStreamPlayer2D2.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
					$AudioStreamPlayer2D2.play()
				2:
					$AudioStreamPlayer2D3.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
					$AudioStreamPlayer2D3.play()
		SFX.LANDING:
			$AudioStreamPlayer2D4.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
			$AudioStreamPlayer2D4.play()
		SFX.STEPING:
			$AudioStreamPlayer2D5.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
			$AudioStreamPlayer2D5.play()
		SFX.JUMPING:
				$AudioStreamPlayer2D6.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
				$AudioStreamPlayer2D6.play()
		SFX.ATTACKING:
				$AudioStreamPlayer2D7.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
				$AudioStreamPlayer2D7.play()
		SFX.TELEPORT:
				$AudioStreamPlayer2D8.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
				$AudioStreamPlayer2D8.play()
		SFX.HURT:
				$AudioStreamPlayer2D9.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
				$AudioStreamPlayer2D9.play()
