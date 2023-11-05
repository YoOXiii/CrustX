Shader "Unlit/WaveTwoColor"
{
    Properties
    {
        // input data
        // _MainTex ("Texture", 2D) = "white" {}
        //_Value ("Value", Float) = 1.0 // internal name, type, default value
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (1, 1, 1, 1)
        _ColorStart ("Color Start", Range(0,1)) = 0
        _ColorEnd ("Color End", Range(0,1)) = 1
        //_Scale ("UV Scale", Float) = 1
        //_Offset ("UV Offset", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" // tag to inform the render pipeline of what type this is
               "Queue"="Transparent" // changes the render order
        }

        Pass
        {
            Cull Off
            ZWrite Off
            ZTest LEqual
            Blend One One // additive
            //Blend DstColor Zero // Multiply
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc" //unity shader built-in helper functions
            
            #define TAU 6.28318530718
            
            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
            
            struct MeshData
            {
                // per-vertex mesh data
                float4 vertex : POSITION; // local space vertex position
                float3 normals : NORMAL; // local space normal direction
                //float tangent : TANGENT; // tangent direction (xyz) tangent sign (w)
                //float4 color : COLOR; // vertex color
                float4 uv0 : TEXCOORD0; // uv0 diffuse/normal map coordinate
                //float4 uv1 : TEXCOORD1; // uv1 coordinates lightmap coordinates
                //float4 uv2 : TEXCOORD1; // uv2 coordinates lightmap coordinates
                //float4 uv3 : TEXCOORD1; // uv3 coordinates lightmap coordinates
            };

            // data passed from the vertex shader to the fragment shader
            // this will interpolate/blend across the triangle
            //struct v2f
            struct Interpolators
            { 
                float4 vertex : SV_POSITION; // clip space position
                float3 normal: TEXCOORD0; // just a channel we want to send data to
                float2 uv : TEXCOORD1; 
                float4 lengthProperties : TEXCOORD2;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals); 
                o.uv = v.uv0; // passthrough
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }
            
            
            float4 frag (Interpolators i) : SV_Target
            {
                float xOffset = cos(i.uv.x * TAU * 8) * .01f;
                float t = cos( (i.uv.y + xOffset - _Time.y * .1f) * TAU * 5) * 0.5 +0.5;
                t *= 1-i.uv.y;
                //return t;

                float topBottomRemover = (abs(i.normal.y) < 0.7);
                float waves = t * topBottomRemover;

                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
                return gradient * waves;
            }
            ENDCG
        }
    }
}
