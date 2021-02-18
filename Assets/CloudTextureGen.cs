using System.Collections;
using System.Collections.Generic;
using UnityEngine;

class CloudTextureGen
{
    public int numCentres = 128;
    public float cloudSize = 20.0f;
    public int cloudOctaves = 4;

    private ComputeShader computeShader;
    private RenderTexture renderTexture;

    private const int Width = 128;
    private const int Height = 128;
    private const int Depth = 128;

    public CloudTextureGen(ComputeShader computeShader)
    {
        this.computeShader = computeShader;
    }

    public RenderTexture GenClouds()
    {
        renderTexture = new RenderTexture(Width, Height, 0, RenderTextureFormat.ARGBFloat);
        renderTexture.dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
        renderTexture.volumeDepth = Depth;
        renderTexture.enableRandomWrite = true;
        renderTexture.wrapMode = TextureWrapMode.Repeat;
        renderTexture.Create();

        List<Vector3> centresList = new List<Vector3>();

        // Random.seed = 0;

        for (int i = 0; i < numCentres; i++)
        {
            centresList.Add(new Vector3(Random.Range(0, Width), Random.Range(0, Height), Random.Range(0, Depth)));
        }

        Vector3[] centres = centresList.ToArray();

        ComputeBuffer centresBuffer = new ComputeBuffer(centres.Length, sizeof(float) * 3);
        centresBuffer.SetData(centres);

        int kernel = computeShader.FindKernel("GenSdf");
        computeShader.SetBuffer(kernel, Shader.PropertyToID("Centres"), centresBuffer);
        computeShader.SetVector(Shader.PropertyToID("Size"), new Vector4(Width, Height, Depth, 0));
        computeShader.SetTexture(kernel, Shader.PropertyToID("Result"), renderTexture);
        computeShader.SetInt(Shader.PropertyToID("NumCentres"), centres.Length);
        computeShader.SetInt(Shader.PropertyToID("NumOctaves"), cloudOctaves);
        computeShader.SetFloat(Shader.PropertyToID("BaseRadius"), cloudSize);
        computeShader.Dispatch(kernel, Width / 8, Height / 8, Depth / 8);

        centresBuffer.Dispose();

        return renderTexture;
    }

}
