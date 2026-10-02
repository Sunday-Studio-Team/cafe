shader_type spatial;
render_mode blend_mix, depth_prepass_alpha,cull_back;

group_uniforms Textures;
uniform sampler2D BC_Texture : source_color, filter_linear_mipmap;
uniform sampler2D N_Texture : hint_normal, filter_linear_mipmap;
uniform sampler2D M_Texture : filter_linear_mipmap;
uniform sampler2D R_Texture : filter_linear_mipmap;
uniform sampler2D AO_Texture : filter_linear_mipmap ;

group_uniforms Color; 
instance uniform float Hue : hint_range(0.0, 360) = 0.0 ;
instance uniform float Hue_Strength : hint_range(0.0, 1.0) = 0.0;
instance uniform float Saturation : hint_range(0.0, 2.0)= 1.0;
instance uniform float Brightness : hint_range(0.0, 10.0) = 1.0;

group_uniforms Normal;
instance uniform float Normal_Strength: hint_range(0.0, 2.0) = 1.0;
instance uniform bool NFlip_Green = false ;

group_uniforms Roughness;
instance uniform float Roughness: hint_range(0.0, 1.0) = 0.8;
instance uniform bool Use_Roughness_Texture = true;

group_uniforms Metallic;
instance uniform float Metallic: hint_range(0.0, 1.0) = 0.0;
instance uniform bool Use_Metallic_Texture = true;

group_uniforms Ambient_Occlusion;
instance uniform float Ao_Strength : hint_range(0.0, 1.0) = 1.0 ;
instance uniform float Ao_Contrast : hint_range(0.0, 2.0) = 1.0;


vec3 HSV_RGB (vec3 HSV) {
	vec3 RGB = abs(fract(HSV.xxx + vec3(0.0 , 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
	return HSV.z * mix( vec3(1), clamp (RGB - 1.0, 0.0, 1.0), HSV.y );
}
vec3 Colorize (vec3 Base) {
	float Sat = clamp (Saturation, 0.0, 2.0);
	vec3 Tint = HSV_RGB( vec3 (fract( Hue / 360.0), min (Sat, 1.0), 1.0));
	
	if (Sat > 1.0) {
		float Lum = dot(Tint, vec3( 0.2126, 0.7152, 0.0722)) ; 
		Tint += (Tint - Lum) * (Sat - 1.0) * 0.5;
	}
	Tint *= max(Brightness, 0.0);
	return mix(Base, Tint, clamp(Hue_Strength, 0.0, 1.0));
}

void fragment() {
	vec4 BaseColor = texture(BC_Texture, UV);
	ALBEDO = Colorize(BaseColor.rgb);
	
	float Rough = Roughness;
	if ( Use_Roughness_Texture) Rough *= texture(R_Texture, UV).r;
	ROUGHNESS =clamp( Rough, 0.0, 1.0);
	
	float Metal =Metallic; 
	if (Use_Metallic_Texture) Metal *= texture(M_Texture, UV).r;
	METALLIC =clamp( Metal, 0.0, 1.0);
	
	float Ao = clamp( texture( AO_Texture, UV).r, 0.0, 1.0);
	Ao =mix (1.0, Ao, clamp(Ao_Strength, 0.0, 1.0)); 
	Ao = 0.5 +(Ao -0.5) * Ao_Contrast;
	AO= clamp( Ao, 0.0, 1.0);
	AO_LIGHT_AFFECT = 1.0;

if (Normal_Strength > 0.001){
	vec3 N= texture(N_Texture, UV).rgb * 2.0 - 1.0;
	if (NFlip_Green) N.y = -N.y; //Use DirectX
	N= normalize(N);
	N.xy *= Normal_Strength;
	NORMAL_MAP = normalize(N)*0.5 +0.5;
	NORMAL_MAP_DEPTH = 1.0;
} else {
	NORMAL_MAP_DEPTH = 0.0;
}}