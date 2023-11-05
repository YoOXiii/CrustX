Shader "Unlit/HeightmapDisplacementOpaque"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // white is the default texture
        _Displacement ("Displacement", Range(0, 1)) = 0
        //_AlphaStrength ("Alpha Strength", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        //Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        //Cull Off
        //ZWrite Off
        //ZTest LEqual
        //Blend One One
        //Blend SrcAlpha OneMinusSrcAlpha

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Displacement;
            float _AlphaStrength;

            Interpolate vert (MeshData v)
            {
                Interpolate o;

                float displacement = (tex2Dlod(_MainTex, float4(v.uv,0,0)).r -0.5f)* _Displacement;
                v.vertex.xyz *= (1+displacement);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolate i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                //col.a *= _AlphaStrength;
                return col;
            }
            ENDCG
        }
    }
}
