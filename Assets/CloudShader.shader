Shader "Unlit/CloudShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightPow ("Light Pow", Range(1,100)) = 1
        _Dim("Cloud Dimming", Range(0,5)) = 1
        _Alpha("Cloud Alpha", Range(0,1)) = 0.5
    }
    SubShader
    {
        // Tags { "RenderType"="Opaque" }
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 100

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        // Blend SrcAlpha One

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
                float4 vertex : SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 world_pos: TEXCOORD1;
            };

            float _LightPow;
            float _Dim;
            float _Alpha;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.world_pos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 tex_col = tex2D(_MainTex, i.uv);
                float3 to_cam_dir = normalize(i.world_pos - _WorldSpaceCameraPos);
                float adot = dot(_WorldSpaceLightPos0.xyz, to_cam_dir);
                float apow = pow(adot, _LightPow);
                float val = apow - _Dim;
                fixed4 col = fixed4(val, val, val, _Alpha * tex_col.x);
                return col;
            }
            ENDCG
        }
    }
}
