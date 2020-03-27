using UnityEngine;

[ExecuteInEditMode]
public class LensFlare : MonoBehaviour
{
    public MeshFilter TargetMeshFilter;
    public MeshRenderer TargetMeshRenderer;

    // Update is called once per frame
    void Update()
    {
        if (null != TargetMeshFilter && null != TargetMeshRenderer)
        {
            Mesh mesh = TargetMeshFilter.mesh;

            if (null != mesh)
            {
                Bounds bounds = mesh.bounds;
                float width = bounds.extents.x * 2;
                float height = bounds.extents.y * 2;

                TargetMeshRenderer.sharedMaterial.SetFloat("_RenderBoardWidth", width);
                TargetMeshRenderer.sharedMaterial.SetFloat("_RenderBoardHeight", height);
            }
        }
    }
}
