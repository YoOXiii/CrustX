Shader "Unlit/Sq16"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        //Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            Interpolate vert (MeshData v)
            {
                Interpolate o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // cosine based palette, 4 vec3 params
            float3 palette(float t)
            {
                float3 a = float3(0.5, 0.5, 0.5);
                float3 b = float3(0.5, 0.5, 0.5);
                float3 c = float3(1.0, 1.0, 1.0);
                float3 d = float3(0.263, 0.416, 0.557);

                return a + b*cos(6.28318*(c*t+d));
            }


            float4 frag (Interpolate i) : SV_Target
            {
                float2 uv = i.uv * 2.0 - 1.0;
                float2 uv0 = uv;
                float3 finalColor = float3(0.0, 0.0, 0.0);

                for (int i = 0; i < 2; i++)
                {
                    uv = frac(uv * 2.0) - 0.5;
                    float d = length(uv); // signed distance function, SDF

                    float3 col = palette(length(uv0) - _Time.y);

                    d = sin(d * 8.0 - _Time.y)/8.0;
                    d = abs(d);
                    d = 0.02 / d;
                    
                    finalColor += col * d;
                }
                float4 fragColor = float4(finalColor, 1.0);
                return fragColor;
            }
            ENDCG
        }
    }
}
