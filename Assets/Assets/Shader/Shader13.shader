Shader "Unlit/Shader13"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1A("Color1A", Color) = (.3, .3, .9, .0)
        _Color1B("Color1B", Color) = (.3, .3, .9, .0)
        _Color2A("Color2A", Color) = (.0, .0, .9, .0)
        _Color2B("Color2B", Color) = (.0, .0, .9, .0)
        _Color3A("Color3A", Color) = (.0, .0, .9, .0)
        _Color3B("Color3B", Color) = (.0, .0, .9, .0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color1A;
            float4 _Color1B;
            float4 _Color2A;
            float4 _Color2B;
            float4 _Color3A;
            float4 _Color3B;

            Interpolate vert (MeshData v)
            {
                Interpolate o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolate i) : SV_Target
            {
                i.uv = frac(i.uv * 2);
                float dist = (i.uv.x - 0.5) * (i.uv.x - 0.5) + (i.uv.y - 0.5) * (i.uv.y - 0.5);
                dist = sqrt(dist);
                float y = cos(dist * 30 - _Time.y * 2) * 0.5 + 0.5;
                float W = cos(_Time.y) * 0.5 + 0.5;
                float4 colX,colY,colZ,col;
                float noise = frac(sin(dot(i.uv.xy, float2(12.9898, 78.233))) * 43758.5453) * 0.05;
                colX = _Color1A * W + _Color1B * (1 - W);
                colY = _Color3A * W + _Color3B * (1 - W);
                colZ = _Color2A * W + _Color2B * (1 - W);
                if (y > 0.9 + noise) col = colX;
                else if (y > 0.7 + noise) col = colY * (y - 0.7) * 10 + colZ * (1 - (y - 0.7) * 10);
                else col = colZ;
                return col;
            }
            ENDCG
        }
    }
}