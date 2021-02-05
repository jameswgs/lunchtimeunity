using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamCloud : MonoBehaviour
{
    public Material mat;
    public GameObject cloud;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Debug.Log("Hello!");
        mat.SetVector("_CloudPosition", cloud.transform.position);
        Graphics.Blit(src, dest, mat);
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
