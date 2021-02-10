Shader "Unlit/Sdf3DDebug"
{
    Properties
    {
        _MainTex ("Texture", 3D) = "white" {}
        _SdfScale("SDF Scale", Range(0.1, 2)) = 1
        _SdfScale0("SDF Scale 0", Range(1, 128)) = 1
        _SdfScale1("SDF Scale 1", Range(1, 128)) = 1
        _SdfScale2("SDF Scale 2", Range(1, 128)) = 1
        _SdfScale3("SDF Scale 3", Range(1, 128)) = 1
        _SdfScale4("SDF Scale 4", Range(1, 128)) = 1
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
            float _SdfScale;
            float _SdfScale0;
            float _SdfScale1;
            float _SdfScale2;
            float _SdfScale3;
            float _SdfScale4;

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
                float colf;
                colf = tex3D(_MainTex, i.worldPos.xyz).x / _SdfScale0;
                colf = colf + (tex3D(_MainTex, i.worldPos.xyz * 2.0f).x / ( _SdfScale1 * 2.0f * _SdfScale ) );
                colf = colf + (tex3D(_MainTex, i.worldPos.xyz * 4.0f).x / ( _SdfScale2 * 4.0f * _SdfScale) );
                colf = colf + (tex3D(_MainTex, i.worldPos.xyz * 8.0f).x / ( _SdfScale3 * 8.0f * _SdfScale) );
                colf = colf + (tex3D(_MainTex, i.worldPos.xyz * 16.0f).x / ( _SdfScale4 * 16.0f * _SdfScale) );

                colf = float3(1,1,1) - colf;
                //if (colf > 0.5) colf = 1.0f;
                //else colf = 0.0f;

                fixed4 col = fixed4(colf, colf, colf, 1.0f);
                return col;
            }
            ENDCG
        }
    }
}
