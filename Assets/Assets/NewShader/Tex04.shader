Shader "Unlit/Tex04"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // white is the default texture
        _Pattern ("Patern", 2D) = "white" {}
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

            sampler2D _Pattern;

            Interpolate vert (MeshData v)
            {
                Interpolate o;
                o.worldPos = mul( UNITY_MATRIX_M, v.vertex );
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolate i) : SV_Target
            {
                //return float4(worldPos, 1.0);
                float2 yzProjection = i.worldPos.yz;
                
                //return float4(topDownProjection, 0.0, 1.0);
                // sample the texture
                float4 moss = tex2D(_MainTex, yzProjection); 
                float4 pattern = tex2D(_Pattern, i.uv).x;

                float4 finalColor = lerp(float4(0.1,0.5,1,1), moss,  pattern);

                return finalColor;
            }
            ENDCG
        }
    }
}
