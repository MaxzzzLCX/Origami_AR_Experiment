using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.WSA;

public class ResetFolding : MonoBehaviour
{
    public GameObject FoldingParentObject;
    private GameObject[] folds;
    public GameObject nextArrow; // 3D object for the "Next" arrow
    public GameObject previousArrow; // 3D object for the "Previous" arrow
    
    private int currentIndex = -1;

    // Start is called before the first frame update
    void Start()
    {
        // Initialization and finding children that start with "FOLD_"
        int children = FoldingParentObject.transform.childCount;
        folds = new GameObject[children];
        bool activeFoldFound = false;
        currentIndex = 0;

        for (int i = 0; i < children; ++i)
        {
            GameObject child = FoldingParentObject.transform.GetChild(i).gameObject;
            if (child.name.StartsWith("FOLD_"))
            {
                folds[i] = child;
            }
        }

        // If no active FOLD was found, activate the first one
        /*
        if (!activeFoldFound)
        {
            currentIndex = 0;
            folds[currentIndex].SetActive(true);
        }
        */

    }

    // Update is called once per frame
    private void OnEnable()
    {
        currentIndex = 0;
        Debug.Log("Origami Model Enabled - Reset to Start");

        if (folds != null && folds.Length > 0)
        {
            currentIndex = 0;
            RestartFolding();
            UpdateArrows();
        }
    }

    private void RestartFolding()
    {
        Debug.Log("Restart Now");
        if (folds != null && folds.Length > 0)
        {
            for (int i = 0; i < folds.Length; ++i)
            {
                if (currentIndex == i)
                {
                    folds[i].gameObject.SetActive(true);
                }
                else
                {
                    folds[i].gameObject.SetActive(false);
                }
            }

        }
    }
    private void UpdateArrows()
    {
        // Disable the "Previous" arrow when the first FOLD is active
        previousArrow.SetActive(currentIndex > 0);

        // Disable the "Next" arrow when the last FOLD is active
        nextArrow.SetActive(currentIndex < folds.Length - 1);
    }
}
