Shader "Unlit/WaveOnlyHeightVertRemap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // white is the default texture
        _VTKTex ("VTK Texture", 2D) = "white" {} // white is the default texture
        _Displacement ("Displacement", Range(0, 1)) = 0
        _Contrast ("Contrast", Range(0.5, 2.0)) = 1.0
        _Brightness ("Brightness", Range(-0.5, 0.5)) = 0.0
        _WaveHeightOffset ("Wave Height Offset", Range(0, 1)) = 0.0
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
            float4 _VTKTex_ST;
            float _Contrast;
            float _Brightness;
            float _WaveHeightOffset;
            
            Interpolate vert (MeshData v)
            {
                Interpolate o;
                float displacement = (tex2Dlod(_MainTex, float4(v.uv,0,0)).r -0.5f)* _Displacement;
                v.vertex.xyz *= (1+displacement);
                v.vertex.xyz += normalize(v.vertex.xyz)*_WaveHeightOffset;
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
                // black edges for bin_color
                _VTKTex_ST.xy = float2(0.96,0.96);
                _VTKTex_ST.zw = float2(0.02,0.02);
                float2 vtkTexUV = i.uv * _VTKTex_ST.xy + _VTKTex_ST.zw;
                float4 vtkColor = tex2D(_VTKTex, vtkTexUV);
                
                // Apply contrast adjustment
                vtkColor.rgb = (vtkColor.rgb - 0.5) * _Contrast + 0.5;
    
                // Apply brightness adjustment
                vtkColor.rgb += _Brightness;

                float luminance = dot(vtkColor.rgb, float3(0.3, 0.59, 0.11));
    
                // Exaggerate the brightness based on the luminance using a power function
                float boostFactor = pow(0.02/luminance, 0.01); // Adjust the 0.5 value to control the intensity of the effect
                
                // Apply the boost factor to the original color
                // if (boostFactor > 1)
                //     vtkColor.rgb += (vtkColor.rgb - 0.5) * (boostFactor - 1);
                // else
                vtkColor.rgb *= boostFactor;
   
                // Make sure the color values are clamped between 0 and 1
                vtkColor.rgb = clamp(vtkColor.rgb, 0, 1);
                
                vtkColor.a = 1;
                return vtkColor;
            }
            ENDCG
        }
    }
}
