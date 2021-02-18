using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(CamCloud))]
public class CamCloudEditor : Editor
{

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        CamCloud camCloud = (CamCloud)target;

        if (GUILayout.Button("Build Object"))
        {
            camCloud.GenClouds();
        }
    }
}
