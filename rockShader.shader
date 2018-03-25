Shader "Custom/rockShader" {
	Properties {
		_NoiseTex("Noise Volume", 3D) = ""{}
		baseColor ("Base Color", Color) = (1.0,0.74,0.58,1.0)
       	colorVariance ("Color Variance", Float) = 1.0
      	bandColors ("Band Max Colors", Int) = 10
       	bandStrength ("Band Strength", Float) = 1.0
       	bandDisplacement ("Band Displacement", Float) = 0.0
       	bandWaviness ("Band Waviness", Float) = 0.2
       	bandWavelength ("Band Wavelength", Float) = 1.0
      	bandHeight ("Band Height", Float) = 10.0
       	noise1Colors ("Noise 1 Max Colors", Int) = 3
       	noise1Strength ("Noise 1 Strength", Float) = 0.3
       	noise1Detail("Noise 1 Detail", Float) = 0.5
       	noise2Colors ("Noise 2 Max Colors", Int) = 4
       	noise2Strength ("Noise 2 Strength", Float) = 0.3
       	noise2Detail("Noise 2 Detail", Float) = 0.1
       	noise3Colors ("Noise 3 Max Colors", Int) = 3
       	noise3Strength ("Noise 3 Strength", Float) = 0.1
       	noise3Detail("Noise 3 Detail", Float) = 20
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		//bumpScale ("Bumpmap Scale", Float) = 1.0
		//_NormalMap ("NormalMap", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		//#include "ClassicNoise3D.hlsl"

		struct Input {

			
			float3 worldPos;
			float3 worldNormal; INTERNAL_DATA
		};

		sampler3D _NoiseTex;
		half _Glossiness;
		half _Metallic;
		float4 baseColor;
        float colorVariance;
        int bandColors;
        float bandStrength;
        float bandDisplacement;
        float bandWaviness;
        float bandWavelength;
        float bandHeight;
        int noise1Colors;
        float noise1Strength;
        float noise1Detail;
        int noise2Colors;
        float noise2Strength;
        float noise2Detail;
        int noise3Colors;
        float noise3Strength;
        float noise3Detail;
        //sampler2D _NormalMap;
        //float bumpScale;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input i, inout SurfaceOutputStandard o) {
			// Add waviness
			float yCoord = i.worldPos.y - bandDisplacement + bandWaviness * tex3Dlod(_NoiseTex, float4(i.worldPos.x * bandWavelength,i.worldPos.y * bandWavelength,i.worldPos.z * bandWavelength,1.0)).a;
			//float yCoord = i.worldPos.y - bandDisplacement + pnoise(float3(i.worldPos.x * bandWavelength,i.worldPos.y * bandWavelength,i.worldPos.z * bandWavelength),100.0) * bandWaviness;
       		int bandInt = bandColors * tex3Dlod(_NoiseTex, float4(0.0, yCoord * (1.0/bandHeight),0.0,1.0)).a;
       		float band = bandStrength * (1.0/bandColors) * bandInt;

       		// Perlin noise 1
       		int noise1Int = noise1Colors * tex3Dlod(_NoiseTex, float4(i.worldPos.x * noise1Detail,i.worldPos.y * noise1Detail,i.worldPos.z * noise1Detail,0.0)).a;
       		float noise1 = noise1Strength * (1.0/noise1Colors) * noise1Int;

       		// Perlin noise 2
       		int noise2Int = noise2Colors * tex3Dlod(_NoiseTex, float4(i.worldPos.x * noise2Detail,i.worldPos.y * noise2Detail,i.worldPos.z * noise2Detail,1.0)).a;
       		float noise2 = noise2Strength * (1.0/noise2Colors) * noise2Int;

       		// Perlin noise 3
       		int noise3Int = noise3Colors * tex3Dlod(_NoiseTex, float4(i.worldPos.x * noise3Detail,i.worldPos.y * noise3Detail,i.worldPos.z * noise3Detail,2.0)).a;
       		float noise3 = noise3Strength * (1.0/noise3Colors) * noise3Int;

       		// Darken each channel by the sum of band, noise1, and noise2
       		float darkenAmt = (1.0/colorVariance) * (band + noise1 + noise2 + noise3);
       		float4 col = float4(baseColor.r - darkenAmt, baseColor.g - darkenAmt, baseColor.b - darkenAmt, baseColor.a);
       		o.Albedo = col.rgb;

       		// Apply bump map
       		//float3 correctWorldNormal = WorldNormalVector ( i, float3( 0, 0, 1 ) );
			//fixed4 norm;
			//if(abs(correctWorldNormal.x)>0.5){norm = tex2D(_NormalMap, i.worldPos.yz * bumpScale);}
			//else if(abs(correctWorldNormal.z)>0.5){norm = tex2D(_NormalMap, i.worldPos.xy * bumpScale);}
			//else{norm = tex2D(_NormalMap, i.worldPos.xz * bumpScale);}
			//o.Normal = norm.xyz;

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = col.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
