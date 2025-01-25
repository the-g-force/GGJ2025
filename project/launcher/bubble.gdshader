shader_type spatial;

uniform float y_threshold = 1.0;
uniform vec4 color = vec4(0.0, 0.0, 1.0, 1.0);


void vertex() {
	if (VERTEX.y > y_threshold - 0.5) {
		COLOR.a = 0.0;
	} else {
		COLOR.a = 0.9;
	}
	COLOR.rgb = color.rgb;
}

void fragment() {
	ALPHA = COLOR.a;
	ALBEDO = COLOR.rgb;
	ROUGHNESS = 0.3;
}
