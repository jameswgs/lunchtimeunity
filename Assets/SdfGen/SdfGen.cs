using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SdfGen : MonoBehaviour
{
    public ComputeShader computeShader;

    private RenderTexture renderTexture;

    private int kernel;

    private int resultId;
    private int centresId;
    private int numCentresId;
    private int sizeId;

    private const int Width = 128;
    private const int Height = 128;
    private const int NumCentres = 8;


    // Start is called before the first frame update
    void Start()
    {
        kernel = computeShader.FindKernel("GenSdf");
        resultId = Shader.PropertyToID("Result");
        centresId = Shader.PropertyToID("Centres");
        numCentresId = Shader.PropertyToID("NumCentres");
        sizeId = Shader.PropertyToID("Size");

        renderTexture = new RenderTexture(Width, Height, 0, RenderTextureFormat.ARGBFloat);
        renderTexture.enableRandomWrite = true;
        renderTexture.wrapMode = TextureWrapMode.Repeat;
        renderTexture.Create();

        GetComponent<Renderer>().material.mainTexture = renderTexture;

        GenSdf();
    }

    void GenSdf()
    {
        List<Vector3> centresList = new List<Vector3>();

        for(int i=0; i<NumCentres; i++) {
            centresList.Add(new Vector3(Random.Range(0, Width), Random.Range(0, Height), 0));
        }

        Vector3[] centres = centresList.ToArray();

        ComputeBuffer buffer = new ComputeBuffer(centres.Length, sizeof(float)*3);
        buffer.SetData(centres);

        computeShader.SetBuffer(kernel, centresId, buffer);
        computeShader.SetVector(sizeId, new Vector4(Width, Height, 0, 0));
        computeShader.SetTexture(kernel, resultId, renderTexture);
        computeShader.SetInt(numCentresId, centres.Length);
        computeShader.Dispatch(kernel, Width/8, Height/8, 1);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
