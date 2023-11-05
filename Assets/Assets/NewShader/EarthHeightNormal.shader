Shader "Unlit/EarthHeightNormal"
{
    Properties
    {
        _RockAlbedo ("Texture", 2D) = "white" {} // albedo means the surface color after white light has been reflected; base color of the surface
        [NoScaleOffset]_RockNormals ("Normal Map", 2D) = "bump" {} // normal map is a texture that stores the normal vectors of each pixel in tangent space
        [NoScaleOffset]_RockHeight ("Height Map", 2D) = "gray" {} // height map is a texture that stores the height of each pixel
        _NormalIntensity ("Normal Intensity", Range(0,1)) = 0.5
        _DisplacementStrength ("Displacement Strength", Range(0,0.2)) = 0
        _Gloss ("Gloss", Range(0,1)) = 0.5
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        
        // Base pass
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define IS_IN_BASE_PASS

            #include "CGLightingTextureNormal.cginc"

            ENDCG
        }
        
        // Add pass
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One // src * 1 + dist * 1
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "CGLightingTextureNormal.cginc"

            ENDCG
        }
    }
}
