shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int cell_size = 16;

void fragment() {
    // 在 Control 节点上，SCREEN_UV 是相对于控件的 UV
    // 如果控件覆盖整个屏幕，SCREEN_UV 就是屏幕 UV
    vec2 final_uv = SCREEN_UV;
    
    if (cell_size > 1) {
        vec2 block_size = SCREEN_PIXEL_SIZE * float(cell_size);
        final_uv = floor(SCREEN_UV / block_size) * block_size + block_size * 0.5;
    }
    
    COLOR = texture(SCREEN_TEXTURE, final_uv);
}