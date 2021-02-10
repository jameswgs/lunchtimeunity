Shader "Hidden/CamClouds"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CloudTexture ("Cloud Texture", 3D) = "white" {}
        _CloudPosition ("Cloud Position", Vector) = (0,0,0,0)
        _CloudScale ("Cloud Scale", Range(1, 128)) = 32.0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float3 viewVector: TEXCOORD1;
            };

            float sdSphere(float3 p, float3 sp, float sr)
            {
                return length(p-sp) - sr;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                // not sure what this is doing, getting the view vector from the UV somehow!
                float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv * 2 - 1, 0, -1));
                o.viewVector = mul(unity_CameraToWorld, float4(viewVector, 0));

                return o;
            }

            sampler2D _MainTex;
            sampler3D _CloudTexture;
            float4 _CloudPosition;
            float _CloudScale;

            fixed4 frag(v2f input) : SV_Target
            {
                float3 srcCol = tex2D(_MainTex, input.uv).rgb;

                float3 rayDir = normalize(input.viewVector);
                float3 curPos = _WorldSpaceCameraPos;
                float mul = 1.0f;
                for (int i = 0; i < 32; i++)
                {
                    float dist = ( tex3D(_CloudTexture, curPos * 0.01f).r - 0.5f ) / _CloudScale;
                    if (dist < 0.5f)
                    {
                        mul *= 0.9f;
                    }
                    curPos = curPos + rayDir * abs(dist);
                }

                return fixed4(srcCol * mul, 1);

                //minDist = clamp(minDist, 0, 1);
                //float dist = length(curPos - _WorldSpaceCameraPos);
                ////return fixed4(dist, dist, dist, 1);
                //return fixed4(col * minDist + invCol * (1.0f - minDist), 1);
            }
            ENDCG
        }
    }
}
