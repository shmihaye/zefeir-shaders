Shader "Skybox/Autumn SkyBox"
{
	 Properties
    {
        _Color1 ("Top Color", Color) = (0.37, 0.52, 0.73, 0)
		_Exponent ("Top Exponent", Float) = 8.0

        _Color2 ("Horizon Color", Color) = (0.89, 0.96, 1, 0)

		_Color3 ("Bottom Color", Color) = (0.89, 0.89, 0.89, 0)
		_Exponent2 ("Bottom Eponent", Float) = 8.0
       
		_Intensity ("Intensity", Float) = 1.0
        
		_SunColor ("Sun Color", Color) = (1, 0.99, 0.87, 1)
		_Intensity2 ("Sun Intensity", Float) = 2.0

		_SunAlpha ("Sun Size", Float) = 550
		_SunBeta ("Sun Gamma", Float) = 1

		_SunVector("Sun Vector", Vector) = (0.269, 0.615, 0.740, 0)

		_SunAzimuth ("Sun Postion X", Float) = 20
		_SunAltitude ("Sun Position Y", Float) = 38

        _Horizon ("Horizon", Range(0, 1)) = 1.0
        _HorizonSize ("Horizon Edge", Range (0, 1)) = 0

    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #define white float4(1, 1, 1, 1)
    #define up float4(0, 1, 0, 0)

    struct appdata
    {
        float4 position : POSITION;
        float3 texcoord : TEXCOORD0;
    };
    
    struct v2f
    {
        float4 position : SV_POSITION;
        float3 texcoord : TEXCOORD0;
    };
    
    half3 _Color1;
	half _Exponent;

    half3 _Color2;

	half3 _Color3;
	half _Exponent2;

    half _Intensity;

	half3 _SunColor;
	half _Intensity2;

	half _SunAlpha;
	half _SunBeta;

	half3 _SunVector;    
    
	half _Horizon;
    half _HorizonSize;
	
	float4 _Gradient_ST;
    
    v2f vert (appdata v)
    {
        v2f o;
        o.position = UnityObjectToClipPos (v.position);
        o.texcoord = v.texcoord;
        return o;
    }
    
    half4 frag (v2f i) : COLOR
    {
        
		float3 v = normalize(i.texcoord);

		float p = v.y;
		float p1 = 1 - pow(min(1, 1 - p), _Exponent);
		float p2 = 1 - pow(min(1, 1 + p), _Exponent2);
		float p3 = 1 - p1 - p2;

		half3 c_sky = _Color1 * p1 + _Color2 * p3 + _Color3 * p2;
		half3 c_sun = _SunColor * min(pow(max(0, dot(v, _SunVector)), _SunAlpha)* _SunBeta, 1);
		
		return half4(c_sky * _Intensity + c_sun * _Intensity2, 0);

		//Horizon Manipulation code that needs to be fixed, other wise basic gradient and Sun is implemented
		/*half d = dot (normalize (i.texcoord), up) * 0.5f + 0.5f;
        half lerpIndex = pow(d, _Exponent);

        if (lerpIndex > _Horizon)
        {
            return lerp (_Color1, _Color2, _Color3, lerpIndex) * _Intensity;
        }
        else
        {
            lerpIndex -= _HorizonSize;
            return lerp (_Color1, _Color2, _Color3, lerpIndex) * _Intensity;
        }*/

    }

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Background" "Queue"="Background" }
        Pass
        {
            ZWrite Off
            Cull Off
            Fog { Mode Off }
            CGPROGRAM
           // #pragma fragmentoption ARB_precision_hint_fastest
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
