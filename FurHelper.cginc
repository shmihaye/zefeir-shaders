// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#ifndef EDO_FUR_SHADER_HELPER
#define EDO_FUR_SHADER_HELPER

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

struct vertInput {
	float4 vertex    : POSITION;
	float4 normal    : NORMAL;
	float2 texcoord  : TEXCOORD0;
	float2 texcoord2 : TEXCOORD1;
};

struct vert2frag {
    SHADOW_COORDS(1) // put shadows data into TEXCOORD1
    fixed3 diff : COLOR0;
    fixed3 ambient : COLOR1;

	float4 position : POSITION;
	float2 uv       : TEXCOORD0;
	float2 uv2      : TEXCOORD1;
};

uniform sampler2D _MainTex;
uniform sampler2D _SubTex;
uniform float4 _Gravity;
uniform float _Length;

vert2frag vert(vertInput v) {

	const float spacing = _Length;
	
	vert2frag o;
	
	float3 forceDirection = float3(0.0, 0.0, 0.0);
	float4 position = v.vertex;
	
	// Wind
	//forceDirection.x = sin(_Time.y + position.x * 0.05) * 0.2;
	//forceDirection.y = cos(_Time.y * 0.7 + position.y * 0.04) * 0.2;
	//forceDirection.z = sin(_Time.y * 0.7 + position.y * 0.04) * 0.2;
	
	float3 displacement = forceDirection + _Gravity.xyz;
	
	float displacementFactor = pow(FUR_OFFSET, 3.0);
	float4 aNormal = v.normal;
	aNormal.xyz += displacement * displacementFactor;
	
	float4 n = normalize(aNormal) * FUR_OFFSET * spacing;
	float4 wpos = float4(v.vertex.xyz + n.xyz, 1.0);
	o.position = UnityObjectToClipPos(wpos);
	o.uv  = v.texcoord;
	o.uv2 = v.texcoord2 * 10.0;

    half3 worldNormal = UnityObjectToWorldNormal(v.normal);
    half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
    o.diff = nl * _LightColor0.rgb;
    o.ambient = half4(0.5, 0.5, 0.5, 1);//ShadeSH9(half4(worldNormal,1));
    // compute shadows data
    TRANSFER_SHADOW(o)

	return o;
}

float4 frag(vert2frag i) : COLOR {
	float4 map = tex2D(_SubTex, i.uv2);
	if (map.a <= 0.0 || map.b < FUR_OFFSET) {
		discard;
	}

	float4 color = tex2D(_MainTex, i.uv);
	color.a = 1.1 - FUR_OFFSET;

    fixed shadow = SHADOW_ATTENUATION(i);
    // darken light's illumination with shadow, keep ambient intact
    fixed3 lighting = i.diff * shadow + i.ambient;
    color.rgb *= lighting;

	return color;
}

#endif
