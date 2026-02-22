shader_type canvas_item;
uniform float dark_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    COLOR = mix(color, vec4(0.0), dark_amount);
}