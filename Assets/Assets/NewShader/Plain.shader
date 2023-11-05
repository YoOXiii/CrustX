Shader "Unlit/Plain"
{
    Properties
    {
        _Value ("value", Float) = 1.0
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
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolate
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolate vert (MeshData v)
            {
                Interpolate o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                //o.normal = v.normal;
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolate i) : SV_Target
            {
                float4 col = float4(i.uv, 0, 1);
                return col;
            }
            ENDCG
        }
    }
}
