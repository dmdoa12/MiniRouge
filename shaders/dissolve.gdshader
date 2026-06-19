shader_type canvas_item;

// 0 = 완전 투명(안 보임), 1 = 화면 전체가 덮임
uniform float cutoff : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.0, 0.3) = 0.08;
uniform sampler2D noise_tex;
uniform vec4 fade_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	float n = texture(noise_tex, UV).r;
	float threshold = cutoff * (1.0 + edge_width) - edge_width;
	float alpha = 1.0 - smoothstep(threshold, threshold + edge_width, n);
	COLOR = vec4(fade_color.rgb, fade_color.a * alpha);
}
