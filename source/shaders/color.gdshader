shader_type canvas_item;

uniform vec4 col:source_color;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	tex.rgba *= col.rgba;
	COLOR = tex;
}