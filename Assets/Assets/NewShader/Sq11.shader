Shader "Unlit/Sq11"
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

            float4 frag (Interpolate i) : SV_Target
            {
                float d = length(i.uv*2-1); // signed distance function, SDF   
                d = sin(d * 8.0 - _Time.y)/8.0;
                d = abs(d);
                d = 0.02 / d;
                float3 neonBule = float3(0.0, 0.5, 1.0);
                float4 fragColor = float4(d*neonBule,1.0);
                return fragColor;
            }
            ENDCG
        }
    }
}
