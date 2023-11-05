Shader "Unlit/Tex11"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // white is the default texture
        _Gloss ("Gloss", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Interpolate
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;

            Interpolate vert (MeshData v)
            {
                Interpolate o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.normal = v.normal;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (Interpolate i) : SV_Target
            {
                
                // diffuse lighting
                float3 N = normalize( i.normal );
                //return float4(N, 1.0);
                float3 L = _WorldSpaceLightPos0.xyz;
                //return float4(L, 1.0);
                float3 lambert = saturate( dot( N, L ) );

                float3 diffuseLight = lambert * _LightColor0.xyz; // saturate() clamps the value between 0 and 1

                // specular lighting
                //return float4(i.wPos, 1);
                float3 V =  normalize( _WorldSpaceCameraPos - i.wPos );
                float3 H = normalize( L + V ); // H is the half vector between L and V
                float3 specularLight = saturate( dot( H, N ) ) * (lambert > 0); // Blinn-Phong

                float specularExponent = exp2( _Gloss * 11.0) + 2.0;
                specularLight = pow(specularLight, specularExponent); // specular exponent

                return float4(specularLight.xxx, 1.0);
                
                //return float4(R, 1.0);

                //return float4(V, 1.0);

                //return float4(diffuseLight, 1.0);
            }
            ENDCG
        }
    }
}
