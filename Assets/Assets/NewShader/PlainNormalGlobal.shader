Shader "Unlit/PlainNormalGlobal"
{
    Properties
    {
        _Value ("value", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
                //o.normal = mul((float3x3)unity_ObjectToWorld, v.normal); //transform to world space
                // o.normal = mul((float3x3)UNITY_MATRIX_M, v.normal); //transform to world space
                //o.normal = mul((float3x3)unity_WorldToObject, o.normal); //transform to object space
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolate i) : SV_Target
            {
                return float4(i.normal, 1);
            }
            ENDCG
        }
    }
}
