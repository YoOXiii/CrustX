Shader "Unlit/HeightmapDisplacementWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // white is the default texture
        _VTKTex ("VTK Texture", 2D) = "white" {} // white is the default texture
        _Displacement ("Displacement", Range(0, 1)) = 0
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        
        Cull Off
        ZWrite Off
        ZTest LEqual
        Blend One One // additive

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
            sampler2D _VTKTex;
            float _Displacement;
            float _AlphaStrength;

            Interpolate vert (MeshData v)
            {
                Interpolate o;
                float displacement = (tex2Dlod(_MainTex, float4(v.uv,0,0)).r -0.5f)* _Displacement;
                v.vertex.x *= (1+displacement);
                v.vertex.y *= (1+displacement);
                v.vertex.z *= (1+displacement);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }

            float4 frag (Interpolate i) : SV_Target
            {
                // sample the texture
                float4 baseColor = tex2D(_MainTex, i.uv);
                float4 vtkColor = tex2D(_VTKTex, i.uv);
                
                //baseColor.a = _AlphaStrength;
                // //float4 finalColor =  vtkColor;
                bool AlphaMask = (vtkColor.r + vtkColor.g + vtkColor.b) / 3 < 0.05 ? 0 : 1;
                return float4(vtkColor.r, vtkColor.g, vtkColor.b*10, 1)+baseColor*(1-AlphaMask);
            }
            ENDCG
        }
    }
}
