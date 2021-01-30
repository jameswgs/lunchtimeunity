Shader "Unlit/CloudShader"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        _WorldPosColourScale ("World Pos Colour Scale", Range(0,5)) = 1
        // TODO - add position of light here
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

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 world_pos : TEXCOORD0; // this feels hacky, but I think it's just a slot for interpolation
            };

            float _WorldPosColourScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.world_pos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 intPart;
                float3 rgb = modf(i.world_pos * _WorldPosColourScale, intPart);
                fixed4 col = fixed4(rgb, 1);
                return col;
            }
            ENDCG
        }
    }
}
