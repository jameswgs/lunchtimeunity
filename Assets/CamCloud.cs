﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamCloud : MonoBehaviour
{
    public Material mat;
    public GameObject cloud;
    public ComputeShader computeShader;
    public float CloudSize = 20.0f;
    public int CloudOctaves = 4;

    private RenderTexture renderTexture;

    private const int Width = 128;
    private const int Height = 128;
    private const int Depth = 128;
    private const int NumCentres = 128;

    // Start is called before the first frame update
    void Start()
    {
        GenClouds();
    }

    public void GenClouds()
    { 
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;

        int kernel = computeShader.FindKernel("GenSdf");
        int resultId = Shader.PropertyToID("Result");
        int centresId = Shader.PropertyToID("Centres");
        int numCentresId = Shader.PropertyToID("NumCentres");
        int sizeId = Shader.PropertyToID("Size");

        renderTexture = new RenderTexture(Width, Height, 0, RenderTextureFormat.ARGBFloat);
        renderTexture.dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
        renderTexture.volumeDepth = Depth;
        renderTexture.enableRandomWrite = true;
        renderTexture.wrapMode = TextureWrapMode.Repeat;
        renderTexture.Create();

        List<Vector3> centresList = new List<Vector3>();

        for (int i = 0; i < NumCentres; i++)
        {
            centresList.Add(new Vector3(Random.Range(0, Width), Random.Range(0, Height), Random.Range(0, Depth)));
        }

        Vector3[] centres = centresList.ToArray();

        ComputeBuffer centresBuffer = new ComputeBuffer(centres.Length, sizeof(float) * 3);
        centresBuffer.SetData(centres);

        computeShader.SetBuffer(kernel, centresId, centresBuffer);
        computeShader.SetVector(sizeId, new Vector4(Width, Height, Depth, 0));
        computeShader.SetTexture(kernel, resultId, renderTexture);
        computeShader.SetInt(numCentresId, centres.Length);
        computeShader.SetInt(Shader.PropertyToID("NumOctaves"), CloudOctaves);
        computeShader.SetFloat(Shader.PropertyToID("BaseRadius"), CloudSize);
        computeShader.Dispatch(kernel, Width / 8, Height / 8, Depth / 8);

        centresBuffer.Dispose();
    }


    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        mat.SetTexture("_CloudTexture", renderTexture);
        mat.SetVector("_CloudPosition", cloud.transform.position);
        Graphics.Blit(src, dest, mat);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
