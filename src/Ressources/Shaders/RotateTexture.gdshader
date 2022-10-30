shader_type canvas_item;


uniform float rotation : hint_range(0,6.28);


void fragment() {
    float sine = sin(rotation);
    float cosine = cos(rotation);

    //UV -= pivot;
	vec2 uv = UV;
    uv.x = uv.x * cosine - uv.y * sine;
    uv.y = uv.x * sine + uv.y * cosine;
    //uv += pivot;

   COLOR = texture(TEXTURE, uv);
}