Shader "Hidden/CamClouds"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CloudTexture ("Cloud Texture", 3D) = "white" {}
        _CloudPosition("Cloud Position", Vector) = (0,0,0,0)
        _CloudRadius("Cloud Radius", Range(1, 128)) = 32.0
        _CloudScale("Cloud Scale", Range(1, 128)) = 32.0
        _CloudThickness("Cloud Thickness", Range(0, 1)) = 0.1
        _Steps("Ray Steps", Range(1, 256)) = 32
        _CloudCol("Cloud Colour", Color) = (0,0,0,0)
        _InCloudStep("In Cloud Step", Range(0.005, 1.0)) = 0.01
        _MaxDepth("Maximum Depth", Range(1, 1024)) = 1024
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

            sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
            sampler3D _CloudTexture;
            float4 _CloudPosition;
            float _CloudRadius;
            float _CloudScale;
            float _CloudThickness;
            float4 _CloudCol;
            int _Steps;
            float _InCloudStep;
            float _MaxDepth;

            fixed4 frag(v2f input) : SV_Target
            {
                // the cam space depth
                float zBuf = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, input.uv));
                // the rendered colour to effect 
                float3 srcCol = tex2D(_MainTex, input.uv).rgb;

                float3 rayDir = normalize(input.viewVector);
                float3 curPos = _WorldSpaceCameraPos;
                float curDepth = 0;
                float mul = 1.0f;
                float invPerStepThickness = 1.0f - (_CloudThickness * _InCloudStep);
                for (int i = 0; i < _Steps; i++)
                {
                    // if the ray hasn't intersected the rendered stuff
                    if (curDepth < zBuf && curDepth < _MaxDepth)
                    {
                        float dist = ( tex3D(_CloudTexture, curPos / _CloudScale).r ) - _CloudRadius;
                        float absDist = abs(dist);

                        float step = absDist + 0.1f;

                        // if we're inside 
                        if (dist < 0.0f)
                        {
                            // reduce the final colour amount
                            mul *= invPerStepThickness;

                            // step a small way through the cloud
                            step = _InCloudStep;
                        }
                        else
                        {
                            // if we're outside
                            // step a bit more than the towards the edge
                            // so we don't end up right on the edge, but
                            // either inside or outisde
                            step = absDist + 0.1f;
                        }

                        curPos += rayDir * step;
                        curDepth += step;
                    }
                }

                float3 foggedCol = srcCol * mul;

                return fixed4(srcCol * mul + _CloudCol * (1 - mul), 1);

            }
            ENDCG
        }
    }
}
