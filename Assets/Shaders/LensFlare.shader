Shader "YiLiang/Effect//LensFlare"
{
    Properties
    {
       _VerticalBillboarding ("Vertical Billboard", float) = 0.5
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
				float4 screenPos : TEXCOORD1;
            };

            float _VerticalBillboarding;

            v2f vert (appdata v)
            {
                v2f o;
                
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

				o.screenPos = ComputeNonStereoScreenPos(o.vertex);

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

			fixed4 LightRay(float4 screenPos)
			{
				float screenRatio = _ScreenParams.x / _ScreenParams.y;

				//算出在屏幕左下角（0, 0）为原点，范围为[0, 1]的坐标
				float2 normScreenPos = (float2(screenPos.x / screenPos.w, screenPos.y / screenPos.w));
				float2 centerNormScreenPos = (normScreenPos - float2(0.5, 0.5));

				centerNormScreenPos.x = centerNormScreenPos.x * screenRatio;

				float atanv = atan2(centerNormScreenPos.x, centerNormScreenPos.y);
				//float dotPos = dot(centerNormScreenPos, centerNormScreenPos)*5;

				//float rz = pow(abs(frac(atanv*0.8 + 0.12) - 0.5), 3.0);

				//取余数
				float fracv = abs(frac(atanv) - 0.5);

				//平滑
				float powv = clamp(pow(fracv, 3.0), 0, 1);

				return float4(powv, powv, powv, 0);
			}

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 sunColor = Sun(i.uv) + LightRay(i.screenPos);

                return sunColor;
            }
            ENDCG
        }
    }
}