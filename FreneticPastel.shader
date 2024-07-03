Shader "Frenetic/PastelRainbow"
{
    Properties
    {
        [Header(Textures)] [Space] [Space]
        _MainTex ("Main Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Glossiness ("Glossiness", Range(0,1)) = 0.5
        [Header(Noise and colors)] [Space] [Space]
        _NoiseScale ("Noise Scale", Float) = 10
        _Speed ("Animation Speed", Float) = 0.5
        _ColorTemp ("Color Temperature", Range(-1,1)) = 0
        _Smoothness ("Color Smoothness", Range(0.01,1)) = 1
        _ColorIntensity ("Color Intensity", Range(0,1)) = 1
    }
    SubShader
    {
        Tags {"Queue"="Geometry" "RenderType"="Opaque"}
        LOD 100

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _MaskTex;
        float _NoiseScale;
        float _Speed;
        float _Smoothness;
        float _ColorIntensity;
        float _Metallic;
        float _Glossiness;
        float _ColorTemp;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MaskTex;
            float3 worldPos;
        };

        static const float3 colors[8] = {
            float3(1.00, 0.70, 0.75),
            float3(1.00, 0.80, 0.60),
            float3(1.00, 0.95, 0.60),
            float3(0.70, 0.90, 0.70),
            float3(0.60, 0.80, 0.95),
            float3(0.80, 0.70, 0.95),
            float3(0.95, 0.70, 0.80),
            float3(0.85, 0.85, 0.95)
        };

        float2 random2(float2 st)
        {
            st = float2(dot(st,float2(127.1,311.7)),
                        dot(st,float2(269.5,183.3)));
            return -1.0 + 2.0*frac(sin(st)*43758.5453123);
        }

        float noise(float2 st) 
        {
            float2 i = floor(st);
            float2 f = frac(st);

            float2 u = f*f*(3.0-2.0*f);

            return lerp( lerp( dot( random2(i + float2(0.0,0.0) ), f - float2(0.0,0.0) ), dot( random2(i + float2(1.0,0.0) ), f - float2(1.0,0.0) ), u.x), lerp( dot( random2(i + float2(0.0,1.0) ), f - float2(0.0,1.0) ), dot( random2(i + float2(1.0,1.0) ), f - float2(1.0,1.0) ), u.x), u.y);
        }

        float3 getColor(float t) {
            t = frac(t);
            float index = t * 8;
            int i = (int)index;
            float f = frac(index);
            f = smoothstep(0, _Smoothness, f);
            return lerp(colors[i], colors[(i + 1) % 8], f);
        }

        float3 adjustColorTemperature(float3 color, float temperature) {
            float3 warm = float3(1.0, 0.9, 0.8);
            float3 cool = float3(0.8, 0.9, 1.0);
            return lerp(color * cool, color * warm, temperature * 0.5 + 0.5);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_MainTex * _NoiseScale;
            float time = _Time.y * _Speed;
            
            float2 gay = float2(
                sin(IN.worldPos.x * 0.1 + _Time.y * 0.2) * 0.75,
                cos(IN.worldPos.z * 0.1 + _Time.y * 0.3) * 0.5
            );
            uv += gay;
                        
            float3 c = lerp(float3(0.5, 0.5, 0.5), getColor(smoothstep(-0.5, -0.5 + _Smoothness, (noise(uv + float2(sin(uv.y * 10 + time), cos(uv.x * 10 + time))) + noise((uv * 1.5 + float2(100, 100)) + float2(cos(uv.x * 10 * 0.7 - time * 0.8), sin(uv.y * 10 * 0.7 - time * 0.8)))) * 0.5) + time * 0.1), _ColorIntensity);
            
            o.Albedo = lerp(tex2D(_MainTex, IN.uv_MainTex).rgb, adjustColorTemperature(c, _ColorTemp), dot(tex2D(_MaskTex, IN.uv_MaskTex).rgb, float3(0.299, 0.587, 0.114)));
            o.Emission = adjustColorTemperature(c, _ColorTemp) * dot(tex2D(_MaskTex, IN.uv_MaskTex).rgb, float3(0.299, 0.587, 0.114)) * (0.5 + (noise(uv + float2(sin(uv.y * 10 + time), cos(uv.x * 10 + time))) + noise((uv * 1.5 + float2(100, 100)) + float2(cos(uv.x * 10 * 0.7 - time * 0.8), sin(uv.y * 10 * 0.7 - time * 0.8)))) * 0.5 * 0.5);

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
