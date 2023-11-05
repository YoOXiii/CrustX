Shader "Custom/UVToSphereMapping"
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

            #define PI 3.14159265
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 sphereCoord : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                float theta = v.uv.x * 360.0 - 180.0;
                float phi = v.uv.y * 180.0 - 90.0;

                o.sphereCoord.x = cos(radians(phi)) * cos(radians(theta));
                o.sphereCoord.y = sin(radians(phi));
                o.sphereCoord.z = cos(radians(phi)) * sin(radians(theta));

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float u = (atan2(i.sphereCoord.z, i.sphereCoord.x) / (2.0 * PI) + 0.5);
                float v = (asin(i.sphereCoord.y) / PI + 0.5);
                half4 col = tex2D(_MainTex, float2(u, v));
                return col;
            }
            ENDCG
        }
    }
}
