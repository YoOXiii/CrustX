Shader "Unlit/Sq02"
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
                float4 fragColor = float4(0.0, 1-i.uv.y, 0.0, 1.0);
                return fragColor;
            }
            ENDCG
        }
    }
}
