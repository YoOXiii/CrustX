Shader "Unlit/CGSky"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 viewDir : TEXCOORD0;
            };

            struct v2f
            {
                float3 viewDir : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            #define TAU 6.283185307179586476925286766559
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewDir = v.viewDir;
                return o;
            }

            float2 DirToRectilinear( float3 dir )
            {
                float x = atan2(dir.z, dir.x) / TAU + 0.5; // atan2: -TAU/2 to TAU/2; 0-1
                //float y = dir.y * 0.5 + 0.5; // 0-1
                float y = asin(dir.y) / TAU * 2 + 0.5; // asin: -PI/2 to PI/2; 0-1
                return float2(x,y);
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2Dlod(_MainTex, float4(DirToRectilinear(i.viewDir),0,0));
                //return float4(i.viewDir,1);
                return col;
            }
            ENDCG
        }
    }
}
