using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamCloud : MonoBehaviour
{
    public Material material;
    public ComputeShader computeShader;
    public Transform container;
    public int numCentres = 128;
    public float cloudSize = 20.0f;
    public int cloudOctaves = 4;

    private CloudTextureGen cloudTexture;

    // Start is called before the first frame update
    void Start()
    {
        cloudTexture = new CloudTextureGen(computeShader);
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
        GenClouds();
    }

    public void GenClouds()
    {
        cloudTexture.numCentres = numCentres;
        cloudTexture.cloudSize = cloudSize;
        cloudTexture.cloudOctaves = cloudOctaves;
        material.SetTexture("_CloudTexture", cloudTexture.GenClouds());
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        material.SetVector("_BoundsMin", container.position - container.localScale / 2);
        material.SetVector("_BoundsMax", container.position + container.localScale / 2);
        Graphics.Blit(src, dest, material);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
