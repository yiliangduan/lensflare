Shader "YiLiang/Effect//LensFlare"
{
    Properties
    {
       _VerticalBillboarding ("Vertical Billboard", float) = 0.5

	   _LightRay ("Light Ray Rotation", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float4 localPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
            };

            float _VerticalBillboarding;

			float _LightRay;

            float _RenderBoardWidth;
            float _RenderBoardHeight;

            v2f vert (appdata v)
            {
                v2f o;
                
				float4 clipPos = UnityObjectToClipPos(v.vertex);

                //billboard
                float3  viewerLocal = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                float3  localDir = viewerLocal - float3(0, 0, 0);  

                localDir.y = lerp(0, localDir.y, _VerticalBillboarding);                
                localDir = normalize(localDir);

                float3  upLocal = abs(localDir.y) > 0.999f ? float3(0, 0, 1) : float3(0, 1, 0);
                float3  rightLocal = normalize(cross(localDir, upLocal));
                
                upLocal = cross(rightLocal, localDir);  

                float3  BBLocalPos = rightLocal * v.vertex.x + upLocal * v.vertex.y;
				o.vertex = UnityObjectToClipPos(float4(BBLocalPos, 1));
                o.uv = v.uv;

				o.localPos = v.vertex;
				o.screenPos = ComputeScreenPos(clipPos);

                return o;
            }

            fixed4 Sun(float2 uv)
            {
                float3 rd = float3(uv.x - 0.5, uv.y - 0.5, -1);
            
                rd *= -2.8;
                rd = normalize(rd);

                float rdl = clamp(dot(rd, float3(0, 0, 1)), 0, 1);

                float3 color = 0.8 * float3(1, 0.9, 0.9) * exp2(rdl * 650 -650);
                color += 0.3 * float3(1, 1, 0.1) * exp2(rdl * 100 -100);
                color += 0.5 * float3(1, 0.7, 0) * exp2(rdl * 50 -50);
                color += 0.4 * float3(1, 0, 0.05) * exp2(rdl * 10 -10);

                float alpha = clamp(0, exp2(rdl * 200 -200), 1);

                return float4(color, alpha);
            }

			fixed4 LightRay(float2 vertexPos)
			{
				float atanv = atan2(vertexPos.x, vertexPos.y);

				//取余数
				float fracv = abs(frac(atanv) - 0.5);

				//平滑
				float powv = clamp(pow(fracv, 3.0), 0, 1);

				//衰减
				float attenuation = dot(vertexPos, vertexPos);
				float alpha = powv * (clamp((1-attenuation * 0.6), 0, 1) * attenuation);

				//射线
				fixed4 rayColor = fixed4(powv, powv, powv, alpha);

				return rayColor;
			}

			float Flare(float2 vertex)
			{
				float flare = 1;
                float2 vertexNorm = float2(vertex.x / _RenderBoardWidth, vertex.y / _RenderBoardHeight);

				float absVertex = abs(vertexNorm);
				
				float weight = max(max(abs(vertexNorm.y*0.385 - absVertex.x*1.176), abs(vertexNorm.y + absVertex.x*0.727)), -vertexNorm.y*1.237);

				flare = clamp(0.02 - pow(weight, 2), 0, 1) * 10;

				return flare;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 sunColor = Sun(i.uv);
				fixed4 lightRay = LightRay(i.localPos);

				fixed4 sunAndRay = (sunColor + lightRay * (1 - sunColor.a));

				float flare = Flare(i.localPos.xy + 0.04*i.screenPos.xy);
				fixed flareAnd = flare > 0 ? 1 : 0;
                fixed4 flareColor = fixed4(flareAnd, flareAnd, flareAnd, flare);

				fixed4 outputColor = sunAndRay;

				return outputColor;
            }

            ENDCG
        }
    }
}