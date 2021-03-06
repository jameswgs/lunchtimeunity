﻿Shader "Unlit/SdfDebug"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SdfScale ("SDF Scale", Range(1, 128)) = 1
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
                float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SdfScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                float3 inv = float3(1.0f, 1.0f, 1.0f) - (tex2D(_MainTex, i.worldPos.xy).xyz / _SdfScale);
                fixed4 col = fixed4(inv, 1.0f);
                return col;
            }
            ENDCG
        }
    }
}
