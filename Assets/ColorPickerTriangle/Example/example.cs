﻿using UnityEngine;
using System.Collections;

public class example : MonoBehaviour {

    public GameObject ColorPickedPrefab;
    private ColorPickerTriangle CP;
    private bool isPaint = false;
    private GameObject go;
    private Material mat;

    void Start()
    {
        mat = GetComponent<MeshRenderer>().material;
    }

    void Update()
    {
        if (isPaint)
        {
            mat.color = CP.TheColor;
        }
    }

    void OnMouseDown()
    {
        if (isPaint)
        {
            StopPaint();
        }
        else
        {
            StartPaint();
        }
    }

    private void StartPaint()
    {
        go = (GameObject)Instantiate(ColorPickedPrefab, transform.position + Vector3.up, Quaternion.identity);
        go.transform.localScale = Vector3.one;
        go.transform.rotation = Quaternion.Euler(0 , 180, 0);
        //go.transform.LookAt(Camera.main.transform);
        CP = go.GetComponent<ColorPickerTriangle>();
        CP.SetNewColor(mat.color);
        isPaint = true;
    }

    private void StopPaint()
    {
        Destroy(go);
        isPaint = false;
    }
}
