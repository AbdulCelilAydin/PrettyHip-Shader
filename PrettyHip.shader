Shader "Custom/MainImageShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Resolution("Resolution", Vector) = (1920, 1080, 0, 0)
        _mTime("Time", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _Resolution;
            float _mTime;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float2 rotateUV(float2 uv, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                return float2(
                    c * uv.x - s * uv.y,
                    s * uv.x + c * uv.y
                );
            }

            float fract(float x) { return x - floor(x); }

            float2 fract(float2 x) { return float2(fract(x.x), fract(x.y)); }

            float length2(float2 p) { return sqrt(p.x * p.x + p.y * p.y); }

            float4 frag(v2f i) : SV_Target
            {
                float2 fragCoord = i.uv * _Resolution.xy;
                float aspect = _Resolution.y / _Resolution.x;
                float value;

                float2 uv = fragCoord / _Resolution.x;
                uv -= float2(0.5, 0.5 * aspect);

                float rot = 3.14159 / 4.0;
                uv = rotateUV(uv, rot);

                uv += float2(0.5, 0.5 * aspect);
                uv.y += 0.5 * (1.0 - aspect);

                float2 pos = 10.0 * uv;
                float2 rep = fract(pos);
                float dist = 2.0 * min(min(rep.x, 1.0 - rep.x), min(rep.y, 1.0 - rep.y));
                float squareDist = length2(floor(pos) + float2(0.5,0.) - float2(5.0,0.));

                float edge = sin(_Time*_mTime - squareDist * 0.5) * 0.5 + 0.5;
                edge = (_Time*_mTime - squareDist * 0.5) * 0.5;
                edge = 2.0 * fract(edge * 0.5);

                value = fract(dist * 2.0);
                value = lerp(value, 1.0 - value, step(1.0, edge));
                edge = pow(abs(1.0 - edge), 2.0);

                value = smoothstep(edge - 0.05, edge, 0.95 * value);

                value += squareDist * 0.1;

                float4 fragColor = lerp(
                    float4(1.0, 1.0, 1.0, 1.0), 
                    float4(0.5, 0.75, 1.0, 1.0), 
                    value
                );
                fragColor.a = 0.25 * saturate(value);

                return fragColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
