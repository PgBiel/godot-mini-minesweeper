shader_type canvas_item;

void fragment() {
	vec2 texture_size = 1. / TEXTURE_PIXEL_SIZE;
	float width_height_proportion = texture_size.x / texture_size.y;
	// convert width percentage to height percentage
	// in case resolution isn't a square
	// for tiles, the texture is the atlas, a horizontal array of 32 x 32 tiles
	// use 'fract' to repeat the pattern for every tile in the atlas
	// (if you hit 1.0, go back to 0.0)
	vec2 converted_uv = vec2(fract(UV.x * width_height_proportion), UV.y);

	// circle with size of 1/2 height
	float center_distance = distance(vec2(0.5), converted_uv);

	// only display the circle (for >0.5 distance, 0 alpha)
	COLOR.a = 1. - smoothstep(0.43, 0.5, center_distance);
}
