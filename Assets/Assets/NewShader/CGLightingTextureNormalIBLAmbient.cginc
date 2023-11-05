#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING
#define TAU 6.283185307179586476925286766559

struct MeshData
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent: TANGENT; // xyz: tangent, w: tangent sign
};

struct Interpolate
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 tangent : TEXCOORD2;
    float3 bitangent : TEXCOORD3;
    float3 wPos : TEXCOORD4;
    LIGHTING_COORDS(5, 6)
};

sampler2D _RockAlbedo;
float4 _RockAlbedo_ST;
sampler2D _RockNormals;
sampler2D _RockHeight;
float _Gloss;
float4 _Color;
float4 _AmbientLight;
sampler2D _DiffuseIBL;
float _NormalIntensity;
float _DisplacementStrength;

float2 Rotate( float2 v, float angRad)
{
    float ca = cos(angRad);
    float sa = sin(angRad);
    return float2( v.x * ca - v.y * sa, v.x * sa + v.y * ca);
}

float2 DirToRectilinear( float3 dir )
{
    float x = atan2(dir.z, dir.x) / TAU + 0.5; // atan2: -TAU/2 to TAU/2; 0-1
    float y = asin(dir.y) / TAU * 2 + 0.5; // asin: -PI/2 to PI/2; 0-1
    return float2(x,y);
}

Interpolate vert (MeshData v)
{
    Interpolate o;
    o.uv = TRANSFORM_TEX(v.uv, _RockAlbedo);
    //o.uv = Rotate(o.uv-0.5, _Time.y) + 0.5; // rotate UVs over time
    //o.vertex.xyz += v.normal * cos(length(o.uv*2-1)*8 + _Time.y) * 0.1;
    float height = tex2Dlod(_RockHeight, float4(o.uv,0,0)).r * 2 - 1; // add height map; vetex cannot decide mip level, so we use tex2Dlod
    v.vertex.xyz += v.normal * (height * _DisplacementStrength); // displace vertex along normal
    o.vertex = UnityObjectToClipPos(v.vertex); 
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
    o.bitangent = cross(o.normal, o.tangent);
    o.bitangent *= v.tangent.w * unity_WorldTransformParams.w; // correctly handle flipping/mirroring

    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_VERTEX_TO_FRAGMENT(o); // transfer lighting data to the fragment shader
    return o;
}

float4 frag (Interpolate i) : SV_Target
{
   
    // #ifdef IS_IN_BASE_PASS
    //     float4 diffuseIBL = tex2Dlod( _DiffuseIBL, float4(DirToRectilinear(i.normal), 0, 1 ) ); // pre-fetch the diffuse IBL
       
    //     return diffuseIBL;  
    // #else
    //     return float4(0,0,0,0);
    // #endif
    float3 rock = tex2D( _RockAlbedo, i.uv);
    float3 surfaceColor = rock * _Color.rgb;

    //return tex2D( _RockNormals, i.uv);
    //return float4(UnpackNormal(tex2D( _RockNormals, i.uv)), 1.0);
    //return float4(UnpackNormal(tex2D( _RockNormals, i.uv)) * 0.5 + 0.5, 1.0);
    float3 tangentSpaceNormal = UnpackNormal(tex2D( _RockNormals, i.uv));
    tangentSpaceNormal = lerp( float3(0,0,1), tangentSpaceNormal, _NormalIntensity); // blend between flat and normal mapped surface (0 = flat, 1 = normal mapped

    float3x3 mtxTangToWorld = {
        i.tangent.x, i.bitangent.x, i.normal.x,
        i.tangent.y, i.bitangent.y, i.normal.y,
        i.tangent.z, i.bitangent.z, i.normal.z
    };

    float3 N = mul(mtxTangToWorld, tangentSpaceNormal); // transform normal from tangent space to world space


    #ifdef USE_LIGHTING
        // diffuse lighting
        // float3 N = normalize( i.normal );
        float3 L = normalize( UnityWorldSpaceLightDir( i.wPos ) ); // light direction
        float attenuation = LIGHT_ATTENUATION(i); // light attenuation
        float3 lambert = saturate( dot( N, L ) );
        float3 diffuseLight = ( lambert * attenuation ) * _LightColor0.xyz; // saturate() clamps the value between 0 and 1
        #ifdef IS_IN_BASE_PASS
            //diffuseLight += _AmbientLight; // adds the indirect diffuse lighting
             float3 diffuseIBL = tex2Dlod( _DiffuseIBL, float4(DirToRectilinear(N), 0, 1 ) ).xyz; // pre-fetch the diffuse IBL
             diffuseLight += diffuseIBL;
        #endif

        // specular lighting
        float3 V =  normalize( _WorldSpaceCameraPos - i.wPos );
        float3 H = normalize( L + V ); // H is the half vector between L and V
        float3 specularLight = saturate( dot( H, N ) ) * (lambert > 0); // Blinn-Phong

        float specularExponent = exp2( _Gloss * 11.0) + 2.0;
        specularLight = pow(specularLight, specularExponent); // specular exponent
        specularLight *= _Gloss; // mitigate energy non-conservation
        specularLight *= attenuation; // attenuate the specular light
        specularLight *= _LightColor0.xyz;

        return float4(diffuseLight * surfaceColor + specularLight, 1.0); // combine diffuse and specular light
    #else
        #ifdef IS_IN_BASE_PASS
            return surfaceColor;
        #else
            return 0;
        #endif
    #endif
}