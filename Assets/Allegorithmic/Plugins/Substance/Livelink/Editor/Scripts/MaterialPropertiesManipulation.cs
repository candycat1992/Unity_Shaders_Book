using AlgSimpleJSON;
using UnityEditor;
using UnityEngine;

namespace Alg
{
	public class TexturePostProcessor : AssetPostprocessor
	{
		void OnPreprocessTexture()
		{
			if (!assetPath.StartsWith("Assets/SP_Textures", System.StringComparison.InvariantCultureIgnoreCase)) return;

			TextureImporter importer = assetImporter as TextureImporter;
			importer.textureCompression = TextureImporterCompression.Uncompressed;
			importer.textureType = assetPath.Contains("_Normal.") ?
				TextureImporterType.NormalMap :
				TextureImporterType.Default;
		}
	}

	public class MaterialPropertiesManipulation
	{
		private static bool SetMaterialTexture(Material material, string property, JSONNode valueNode)
		{
			JSONData data = valueNode as JSONData;
			if (data == null) return false;

			string mapPath = data.Value;

			// Load the texture property
			AssetDatabase.ImportAsset(mapPath);
			Texture2D texture = AssetDatabase.LoadAssetAtPath(mapPath, typeof(Texture2D)) as Texture2D;
			if (!texture)
			{
				Debug.LogWarning(string.Format("Map path '{0}' is not a valid image path", mapPath));
			}

			material.SetTexture(property, texture);
			return texture != null;
		}

		private static bool CheckMaterialProperty(Material material, string property, out int propertyIndex)
		{
			propertyIndex = -1;
			// Check parameter validity
			ShaderInfos shaderInfos = ShadersInfos.GetShaderInfos(material.shader);
			if (shaderInfos == null || !shaderInfos.PropertiesAssociation.ContainsValue(property))
			{
				Debug.LogWarning(string.Format("Unknown '{0}' parameter in shader {1}", property, material.shader.name));
				return false;
			}
			int propertyCount = ShaderUtil.GetPropertyCount(material.shader);
			for (int i = 0; i < propertyCount; ++i)
			{
				if (ShaderUtil.GetPropertyName(material.shader, i).Equals(property))
				{
					propertyIndex = i;
					return true;
				}
			}
			Debug.LogWarning(string.Format("Material '{0}' doesn't contain '{1}' property", AssetDatabase.GetAssetPath(material), property));
			return false;
		}

		public static bool SetMaterialParam(Material material, string property, JSONNode valueNode)
		{
			int propertyIndex;
			if (!CheckMaterialProperty(material, property, out propertyIndex)) return false;

			// Set the property value
			bool succeed = false;
			ShaderUtil.ShaderPropertyType type = ShaderUtil.GetPropertyType(material.shader, propertyIndex);
			switch (type)
			{
				case ShaderUtil.ShaderPropertyType.TexEnv: succeed = SetMaterialTexture(material, property, valueNode); break;
				default:
					Debug.LogWarning(string.Format("{0} property exchange not implemented", type.ToString()));
					break;
			}

			if (!succeed)
			{
				Debug.LogWarning(string.Format("Failed to load property '{0}' value of type {1} on material {2}: {3}", property, type.ToString(), AssetDatabase.GetAssetPath(material), valueNode.Value));
			}
			else
			{
				// Apply property changed post process
				ShaderInfos shaderInfos = ShadersInfos.GetShaderInfos(material.shader);
				if (shaderInfos.PostProcesses.ContainsKey(property))
				{
					shaderInfos.PostProcesses[property](material, valueNode);
				}
			}
			return succeed;
		}
	}
}
