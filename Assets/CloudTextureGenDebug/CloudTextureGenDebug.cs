using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CloudTextureGenDebug : MonoBehaviour
{
    public ComputeShader computeShader;
    public int numCentres = 128;
    public float cloudSize = 20.0f;
    public int cloudOctaves = 4;

    private CloudTextureGen textureGen;

    // Start is called before the first frame update
    void Start()
    {
        textureGen = new CloudTextureGen(computeShader);
        GenClouds();
    }

    public void GenClouds()
    {
        textureGen.numCentres = numCentres;
        textureGen.cloudSize = cloudSize;
        textureGen.cloudOctaves = cloudOctaves;
        GetComponent<Renderer>().sharedMaterial.mainTexture = textureGen.GenClouds();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
