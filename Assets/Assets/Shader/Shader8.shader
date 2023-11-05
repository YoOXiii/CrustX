Shader "Unlit/Shader8"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define PI 3.1415926535897932384626433832795

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolate
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float InverseLerp(float a, float b, float v) // v is between a and b
            {
                return (v - a) / (b - a);
            }

            float Lerp(float a, float b, float v) // v is between 0 and 1
            {
                return a + (b - a) * v;
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
                float dist = (i.uv.x - 0.5) * (i.uv.x - 0.5) + (i.uv.y - 0.5) * (i.uv.y - 0.5);
                dist = sqrt(dist);
                if (dist > 0.22 && dist < 0.28)
                {
                    float w = abs(dist - 0.25);
                    w = InverseLerp(0, 0.03, w);
                    w = Lerp(0.1, 0.9, w);
                    float4 col = (0,0,0,w);
                    return col;
                }
                float4 col = (0,0,0,0.9);
                return col;
            }
            ENDCG
        }
    }
}