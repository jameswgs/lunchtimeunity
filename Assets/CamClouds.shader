Shader "Hidden/CamClouds"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CloudTexture ("Cloud Texture", 3D) = "white" {}
        _CloudRadius("Cloud Radius", Range(-128, 128)) = 0.0
        _CloudScale("Cloud Scale", Range(1, 1024)) = 32.0
        _CloudThickness("Cloud Thickness", Range(0, 1)) = 0.1
        _Steps("Ray Steps", Range(1, 256)) = 32
        _CloudCol("Cloud Colour", Color) = (0,0,0,0)
        _InCloudStep("In Cloud Step", Range(0.005, 1.0)) = 0.01
        _MaxDepth("Maximum Depth", Range(1, 1024)) = 1024
        _NormalEpsilon("Normal Epsilon", Range(0.1, 20)) = 5
        _SurfaceNormalBlend("Surface Normal Blend", Range(0, 1)) = 0
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
            float _CloudRadius;
            float _CloudScale;
            float _CloudThickness;
            float4 _CloudCol;
            int _Steps;
            float _InCloudStep;
            float _MaxDepth;
            float _NormalEpsilon;
            int _SurfaceNormalBlend;

            float sceneSDF(float3 pos)
            {
                return (tex3D(_CloudTexture, pos / _CloudScale).r) - _CloudRadius;
            }

            float3 estimateNormal(float3 p) {
                float EPSILON = _NormalEpsilon;
                return normalize(float3(
                    sceneSDF(float3(p.x + EPSILON, p.y, p.z)) - sceneSDF(float3(p.x - EPSILON, p.y, p.z)),
                    sceneSDF(float3(p.x, p.y + EPSILON, p.z)) - sceneSDF(float3(p.x, p.y - EPSILON, p.z)),
                    sceneSDF(float3(p.x, p.y, p.z + EPSILON)) - sceneSDF(float3(p.x, p.y, p.z - EPSILON))
                 ));
            }

            fixed4 frag(v2f input) : SV_Target
            {
                // the cam space depth
                float zBuf = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, input.uv));
                // the rendered colour to effect 
                float3 srcCol = tex2D(_MainTex, input.uv).rgb;

                float3 rayDir = normalize(input.viewVector);
                float3 curPos = _WorldSpaceCameraPos;
                float3 surfaceNormalCol;
                float curDepth = 0;
                float mul = 1.0f;
                float invPerStepThickness = 1.0f - (_CloudThickness * _InCloudStep);
                bool insideSDF = false;
                for (int i = 0; i < _Steps; i++)
                {
                    // if the ray hasn't intersected the rendered stuff
                    if (curDepth < zBuf && curDepth < _MaxDepth)
                    {
                        float dist = sceneSDF(curPos);
                        float absDist = abs(dist);

                        float step;

                        // if we're inside 
                        if (dist < 0.0f)
                        {
                            if (!insideSDF)
                            {
                                insideSDF = true;
                                surfaceNormalCol = (estimateNormal(curPos) + float3(1.0, 1.0, 1.0)) * 0.5f;
                            }
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
                            step = absDist + 0.5f;
                        }

                        curPos += rayDir * step;
                        curDepth += step;
                    }
                }

                // Show debug normals?
                if (_SurfaceNormalBlend)
                {
                    if (insideSDF)
                    {
                        return fixed4(surfaceNormalCol, 1);
                    }
                    else
                        return fixed4(srcCol, 1);
                }
                else
                {
                    // Regular rendering path
                    return fixed4(srcCol * mul + _CloudCol * (1 - mul), 1);
                }
            }
            ENDCG
        }
    }
}
