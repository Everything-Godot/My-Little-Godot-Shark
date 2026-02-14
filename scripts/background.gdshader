shader_type canvas_item;

uniform vec2 tiling = vec2(1.0, 1.0);
uniform vec2 offset = vec2(0.0, 0.0);

void vertex() {
	UV = UV * tiling + offset * TIME;
}