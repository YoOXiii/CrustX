Shader "Unlit/Tex13"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // white is the default texture
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

            #include "CGLighting.cginc"

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

            #include "CGLighting.cginc"

            ENDCG
        }
    }
}
