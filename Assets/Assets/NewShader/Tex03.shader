Shader "Unlit/Tex03"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // white is the default texture
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}

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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; // ST means scale and offset

            Interpolate vert (MeshData v)
            {
                Interpolate o;
                o.worldPos = mul( UNITY_MATRIX_M, v.vertex );
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); // use the scaling and offset from _MainTex_ST to transform the uv coordinates
                return o;
            }

            float4 frag (Interpolate i) : SV_Target
            {
                //return float4(worldPos, 1.0);
                float2 yzProjection = i.worldPos.yz;
                
                //return float4(topDownProjection, 0.0, 1.0);
                // sample the texture
                float4 col = tex2D(_MainTex, yzProjection); // pick a color from the texture at the xyProjection coordinates in the world space
                return col;
            }
            ENDCG
        }
    }
}
