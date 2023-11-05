Shader "Unlit/Sq07"
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
                float d = abs(length(i.uv*2-1) - 0.5); // signed distance function, SDF
                d = step(0.1, d); // threshold
                float4 fragColor = float4(d, d, d, 1.0);
                return fragColor;
            }
            ENDCG
        }
    }
}
