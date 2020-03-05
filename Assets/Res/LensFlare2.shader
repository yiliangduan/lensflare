Shader "Unlit/LensFlare2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float4 screenPos = o.vertex * 0.5f;
				screenPos.xy = float2(screenPos.x, screenPos.y*_ProjectionParams.x) + screenPos.w;
				screenPos.zw = o.vertex.zw;

				o.screenPos = screenPos;// ComputeNonStereoScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//算出在屏幕左下角（0, 0）为原点，范围为[0, 1]的坐标
				float2 realScreenPos = (float2(i.screenPos.x / i.screenPos.w, i.screenPos.y / i.screenPos.w)) - float2(0.5, 0.5);
				float atanv = atan2(realScreenPos.x, realScreenPos.y);

				float4 col = float4(atanv, atanv, atanv, 1);
				
                return col;
            }
            ENDCG
        }
    }
}
