extends CanvasLayer

const DISSOLVE_SHADER := preload("res://shaders/dissolve.gdshader")

var rect: ColorRect

func _ready() -> void:
	layer = 100
	rect = ColorRect.new()
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var mat := ShaderMaterial.new()
	mat.shader = DISSOLVE_SHADER
	
	var noise := FastNoiseLite.new()
	noise.frequency = 0.05
	var noise_tex := NoiseTexture2D.new()
	noise_tex.width = 512
	noise_tex.height = 512
	noise_tex.noise = noise
	
	mat.set_shader_parameter("noise_tex", noise_tex)
	mat.set_shader_parameter("cutoff", 0.0)
	rect.material = mat
	add_child(rect)
	
func fade_to_black(duration := 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(rect.material, "shader_parameter/cutoff", 1.0, duration)
	await tween.finished

func fade_from_black(duration := 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(rect.material, "shader_parameter/cutoff", 0.0, duration)
	await tween.finished
	
	
	
	
