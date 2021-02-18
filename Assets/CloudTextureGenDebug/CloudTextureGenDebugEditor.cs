using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(CloudTextureGenDebug))]
public class CloudTextureGenDebugEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        CloudTextureGenDebug gen = (CloudTextureGenDebug)target;

        if (GUILayout.Button("Regenerate Cloud Texture"))
        {
            gen.GenClouds();
        }
    }
}
