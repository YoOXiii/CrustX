Shader "Unlit/Shader10"
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

            float InverseLerp(float a, float b, float v) // v is between a and b
            {
                return (v - a) / (b - a);
            }

            float Lerp(float a, float b, float v) // v is between 0 and 1
            {
                return a + (b - a) * v;
            }
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

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
                float y = cos(dist * 10 * PI - _Time.y * 2) * 0.5 + 0.5;
                float4 col;
                if (y > 0.8) 
                {
                  float z = acos(y);
                  z = abs(z);
                  z = InverseLerp(0, acos(0.8), z);
                  z = Lerp(0.1, 0.9, z);
                  col = (0,0,0,z);
                }
                else col = (0,0,0,0.9);
                return col;
            }
            ENDCG
        }
    }
}