Shader "Unlit/CloudTextureGenDebugShader"
{
    Properties
    {
        _MainTex ("Texture", 3D) = "white" {}
        _DistScale("Distance Scale", Range(0.01,1)) = 1
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

            sampler3D _MainTex;
            float4 _MainTex_ST;
            float _DistScale;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float colf;
                colf = tex3D(_MainTex, i.worldPos.xyz).x;
                float s = sign(colf) * _DistScale;
                float r = max(0, s) * colf;
                float b = max(0, -s) * -colf;

                return fixed4(r, 0, b, 1.0f);
            }
                
            ENDCG
        }
    }
    FallBack "Diffuse"
}
