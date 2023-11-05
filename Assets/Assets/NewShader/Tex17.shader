Shader "Unlit/Tex17"
{
    Properties
    {
        _RockAlbedo ("Texture", 2D) = "white" {} // albedo means the surface color after white light has been reflected; base color of the surface
        [NoScaleOffset]_RockNormals ("Normal Map", 2D) = "bump" {} // normal map is a texture that stores the normal vectors of each pixel in tangent space
        [NoScaleOffset]_RockHeight ("Height Map", 2D) = "gray" {} // height map is a texture that stores the height of each pixel
        [NoScaleOffset]_DiffuseIBL ("Diffuse IBL", 2D) = "black" {}
        [NoScaleOffset]_SpecularIBL ("Specular IBL", 2D) = "black" {}
        _NormalIntensity ("Normal Intensity", Range(0,1)) = 1
        _DisplacementStrength ("Displacement Strength", Range(0,0.2)) = 0
        _AmbientLight ("Ambient Light", Color) = (0,0,0,0)
        _SpecIBLIntensity ("Specular IBL Intensity", Range(0,1)) = 1
        
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

            #include "CGLightingTextureAmbientIBLDiffuseSpecular.cginc"

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

            #include "CGLightingTextureAmbientIBLDiffuseSpecular.cginc"

            ENDCG
        }
    }
}
