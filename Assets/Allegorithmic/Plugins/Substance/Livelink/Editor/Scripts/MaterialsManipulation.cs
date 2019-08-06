using AlgSimpleJSON;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;

namespace Alg
{
	public class MeshInfo
	{
		private List<Material> materials_ = new List<Material>();

		public string AssetPath
		{
			get;
			set;
		}

		public int Identifier
		{
			get;
			set;
		}

		public IEnumerable<Material> Materials
		{
			get { return materials_; }
		}

		public void AddMaterials(Material[] materials)
		{
			materials_.AddRange(materials);
		}
	}

	public class MaterialsManipulation
	{
		public static MeshInfo[] MeshesInfoFromGameObject(GameObject gameObject)
		{
			// Associate all renderers and materials to an asset
			// An asset is composed of at least one Mesh
			// It will fail if one asset is rendered multiple times in the game object hierarchy
			Dictionary<string, MeshInfo> meshesInfo = new Dictionary<string, MeshInfo>();
			foreach (Renderer rendererCandidate in gameObject.GetComponentsInChildren<Renderer>())
			{
				Mesh foundMesh = null;
				if (rendererCandidate is MeshRenderer)
				{
					// A MeshRenderer defines materials to apply on a Mesh
					// It implies there is a MeshFilter on the same GameObject referencing the Mesh
					MeshFilter meshFilter = rendererCandidate.GetComponent<MeshFilter>();
					if (meshFilter != null)
					{
						foundMesh = meshFilter.sharedMesh;
					}
				}
				if (rendererCandidate is SkinnedMeshRenderer)
				{
					// A SkinnedMeshRenderer defines materials to apply on a Mesh and references it
					foundMesh = ((SkinnedMeshRenderer)rendererCandidate).sharedMesh;
				}
				if (foundMesh == null) continue;

				string assetPath = AssetDatabase.GetAssetPath(foundMesh);
				Material[] materials = rendererCandidate.sharedMaterials.ToList()
					.Where(m => m != null && ShadersInfos.ContainsShader(m.shader))
					.ToArray();
				if (materials.Length == 0) continue;

				if (!meshesInfo.ContainsKey(assetPath))
				{
					meshesInfo.Add(assetPath, new MeshInfo { AssetPath = assetPath });
				}
				meshesInfo[assetPath].AddMaterials(materials);
				meshesInfo[assetPath].Identifier = gameObject.GetInstanceID();
			}
			return meshesInfo.Values.ToArray();
		}

		private static Material ResolveMaterial(string materialPath)
		{
			Material material = AssetDatabase.LoadAssetAtPath(materialPath, typeof(Material)) as Material;
			if (!material)
			{
				Debug.LogWarning(string.Format("Received loading material parameter request on unknown '{0}' material", materialPath));
			}
			return material;
		}

		public static string SanitizeMaterialName(string materialName)
		{
			// Default material name (if can't be retrieved from mesh) isn't the same
			if (materialName.Equals("No Name"))
			{
				materialName = "DefaultMaterial";
			}

			// HACK: Sanitize the name the same way SP internally do it
			return System.Text.RegularExpressions.Regex.Replace(materialName, @"[\\/#]", "_");
		}

		public static void SetMaterialParamsCommand(JSONNode jsonData)
		{
			JSONClass parameters = jsonData["params"] as JSONClass;
			Material material = ResolveMaterial(jsonData["material"].Value);
			if (!material) return;

			// Load each parameter
			foreach (string parameterName in parameters.Keys)
			{
				MaterialPropertiesManipulation.SetMaterialParam(material, parameterName, parameters[parameterName]);
			}
		}

		public static MeshInfo[] GetSelectedMeshesInfo()
		{
			return Selection.gameObjects
				.ToList()
				.SelectMany(go => MeshesInfoFromGameObject(go))
				.ToArray();
		}
	}
}
