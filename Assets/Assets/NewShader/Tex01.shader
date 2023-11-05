Shader "Unlit/Tex01"
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; // ST means scale and offset

            Interpolate vert (MeshData v)
            {
                Interpolate o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); // use the scaling and offset from _MainTex_ST to transform the uv coordinates
                //o.uv = v.uv;
                return o;
            }

            fixed4 frag (Interpolate i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv); // pick a color from the texture at the uv coordinates
                return col;
            }
            ENDCG
        }
    }
}
