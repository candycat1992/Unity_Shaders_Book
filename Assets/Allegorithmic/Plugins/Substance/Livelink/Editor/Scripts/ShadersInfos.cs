using AlgSimpleJSON;
using System.Collections.Generic;
using UnityEngine;

namespace Alg
{
	public class ShaderInfos
	{
		public delegate void MaterialModifier(Material material);
		public delegate void PropertyChangedPostProcess(Material material, JSONNode json);

		public string ResourceShader { get; set; }
		public string ExportPreset { get; set; }
		public Dictionary<string, string> PropertiesAssociation { get; set; }
		public Dictionary<string, PropertyChangedPostProcess> PostProcesses { get; set; }
		public MaterialModifier EnsureMaterialCompatibility { get; set; }
	}

	public class ShadersInfos
	{
		private static Dictionary<string, ShaderInfos> shadersInfos = new Dictionary<string, ShaderInfos>()
		{
			{
				"Standard",
				new ShaderInfos()
				{
					ResourceShader = "pbr-metal-rough-with-alpha-blending",
					ExportPreset = "Unity 5 (Standard Metallic)",
					PropertiesAssociation = new Dictionary<string, string>() {
						// Associate texture name
						{ "$mesh_$textureSet_AlbedoTransparency", "_MainTex" },
						{ "$mesh_$textureSet_Emission", "_EmissionMap" },
						{ "$mesh_$textureSet_MetallicSmoothness", "_MetallicGlossMap" },
						{ "$mesh_$textureSet_Normal", "_BumpMap" }
					},
					PostProcesses = new Dictionary<string, ShaderInfos.PropertyChangedPostProcess>() {
						// https://docs.unity3d.com/Manual/MaterialsAccessingViaScript.html
						{ "_BumpMap", (m, d) => m.EnableKeyword("_NORMALMAP") },
						{ "_EmissionMap", (m, d) => {
							m.EnableKeyword("_EMISSION");
							m.SetColor("_EmissionColor", new Color(1.0f, 1.0f, 1.0f)); // Emission modulation
						} },
						{ "_MetallicGlossMap", (m, d) => m.EnableKeyword("_METALLICGLOSSMAP") }
					},
					EnsureMaterialCompatibility = m =>
					{
						m.SetColor("_Color", new Color(1.0f, 1.0f, 1.0f)); // Albedo modulation https://support.allegorithmic.com/documentation/display/SPDOC/Unity+5
						m.SetColor("_EmissionColor", new Color(0.0f, 0.0f, 0.0f)); // Emission modulation
						m.SetFloat("_GlossMapScale", 1.0f); // Smoothness modulation
						m.SetFloat("_OcclusionStrength", 1.0f); // Occlusion modulation
						m.SetFloat("_SmoothnessTextureChannel", 0); // Set smoothness source to 'Metallic Alpha'
					}
				}
			}
		};

		public static bool ContainsShader(Shader shader)
		{
			return shadersInfos.ContainsKey(shader.name);
		}

		public static ShaderInfos GetShaderInfos(Shader shader)
		{
			ShaderInfos info;
			shadersInfos.TryGetValue(shader.name, out info);
			return info;
		}
	}
}
