Shader "Unlit/Tex06"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // white is the default texture
        _MipSampleLevel ("MIP", float) = 0
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

            float _MipSampleLevel;

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
                
                // sample the texture
                float4 moss = tex2Dlod(_MainTex, float4( yzProjection, _MipSampleLevel.xx) ); // assuming isotropic texture 

                return moss;
            }
            ENDCG
        }
    }
}
