#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING

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
    LIGHTING_COORDS(3, 4)
};

sampler2D _MainTex;
float4 _MainTex_ST;
float _Gloss;
float4 _Color;

Interpolate vert (MeshData v)
{
    Interpolate o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_VERTEX_TO_FRAGMENT(o); // transfer lighting data to the fragment shader
    return o;
}

float4 frag (Interpolate i) : SV_Target
{
    #ifdef USE_LIGHTING
        // diffuse lighting
        float3 N = normalize( i.normal );
        float3 L = normalize( UnityWorldSpaceLightDir( i.wPos ) ); // light direction
        float attenuation = LIGHT_ATTENUATION(i); // light attenuation
        float3 lambert = saturate( dot( N, L ) );
        float3 diffuseLight = ( lambert * attenuation ) * _LightColor0.xyz; // saturate() clamps the value between 0 and 1

        // specular lighting
        float3 V =  normalize( _WorldSpaceCameraPos - i.wPos );
        float3 H = normalize( L + V ); // H is the half vector between L and V
        float3 specularLight = saturate( dot( H, N ) ) * (lambert > 0); // Blinn-Phong

        float specularExponent = exp2( _Gloss * 11.0) + 2.0;
        specularLight = pow(specularLight, specularExponent); // specular exponent
        specularLight *= _Gloss; // mitigate energy non-conservation
        specularLight *= attenuation; // attenuate the specular light
        specularLight *= _LightColor0.xyz;

        return float4(diffuseLight * _Color + specularLight, 1.0); // combine diffuse and specular light
    #else
        #ifdef IS_IN_BASE_PASS
            return _Color;
        #else
            return 0;
        #endif
    #endif
}