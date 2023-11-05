Shader "Unlit/Tex07"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // white is the default texture
        _AlphaStrength ("Alpha Strength", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define TAU 6.28318530718

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolate
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaStrength;

            float GetWave (float coord)
            {
                float wave = cos( (coord - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5; 
                wave *= 1-coord;
                return wave;
            }

            Interpolate vert (MeshData v)
            {
                Interpolate o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolate i) : SV_Target
            {
                // sample the texture
                float4 pattern = tex2D(_MainTex, i.uv);
                // apply wave
                return GetWave(pattern) * _AlphaStrength;
            }
            ENDCG
        }
    }
}
