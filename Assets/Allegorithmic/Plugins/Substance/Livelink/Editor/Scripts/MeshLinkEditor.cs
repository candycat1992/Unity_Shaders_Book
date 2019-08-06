using UnityEngine;
using UnityEditor;
using AlgSimpleJSON;
using System.IO;
using System.Collections.Generic;
using System.Linq;

namespace Alg
{
	/* Allows to edit a mesh materials inside Substance Painter by using a persistent connection between both programs
	 *
	 * The connection is based on a WebSocket connection with a simple command protocol: "[COMMAND KEY] [JSON DATA]"
	 * List of commands to which this plugin is able to answer:
	 * - SET_MATERIAL_PARAMS: Set the parameters values of a specific material
	 * - OPENED_PROJECT_INFO: Receive information from current opened project in Painter (project url and unity link identifier)
	 */
	[InitializeOnLoad]
	public class MeshLinkEditor
	{
		private static Stack<string> messages = new Stack<string>(); // Message queue to be treated in main thread
		private static WebSocketSharp.WebSocket webSocket; // Current connection

		// Static constructor
		static MeshLinkEditor()
		{
			Application.runInBackground = true; // Update even if the window haven't the focus
			EditorApplication.update += HandleMessagesQueue;

			// Try auto connection to Substance Painter:
			// - ask information on project opened in Painter
			// - if this match a game object of the Unity project; try to auto connect it
			AskForProjectInfo();
		}

		private static void HandleMessagesQueue()
		{
			lock (messages)
			{
				while (messages.Count > 0)
				{
					// Parse string to extract data with format: "[COMMAND KEY] [JSON DATA]"
					string message = messages.Pop();
					int separator = message.IndexOf(' ');
					string command = message.Substring(0, separator);
					string jsonString = message.Substring(separator + 1);
					JSONNode node = JSON.Parse(jsonString);

					switch (command.ToUpper())
					{
						case "SET_MATERIAL_PARAMS":
							MaterialsManipulation.SetMaterialParamsCommand(node);
							UnityEditorInternal.InternalEditorUtility.RepaintAllViews();
							break;
						case "OPENED_PROJECT_INFO":
							TryConnectToProject(node);
							break;
						default:
							Debug.LogError(string.Format("Unknown command {0}", command));
							break;
					}
				}
			}
		}

		private static void ConnectSocket()
		{
			// Close previous connection if needed
			if (webSocket != null)
			{
				webSocket.Close();
				webSocket = null;
			}

			// Connect to Substance Painter
			webSocket = new WebSocketSharp.WebSocket("ws://localhost:6404");
			webSocket.OnMessage += (sender, e) =>
			{
				lock (messages)
				{
					messages.Push(e.Data);
				}
			};
			webSocket.Connect();
		}

		private static string GetSpProjectPath(MeshInfo meshInfo)
		{
			string meshName = Path.GetFileNameWithoutExtension(meshInfo.AssetPath);
			string meshPath = Path.GetFullPath(Path.Combine(Path.GetDirectoryName(Application.dataPath), meshInfo.AssetPath).ToString());
			string folderPath = Path.GetDirectoryName(meshPath);

			// Put Substance Painter projects in a folder name started with '.' to hide it from the Unity asset browser
			return Path.Combine(Path.Combine(folderPath, ".sp"), meshName + ".spp");
		}

		private static JSONNode GetSpDataLinkToSend(MeshInfo meshInfo, string substancePainterProjectPath)
		{
			// Prepare data to send to SP
			string workspacePath = Path.GetDirectoryName(Application.dataPath);
			string meshPath = Path.GetFullPath(Path.Combine(workspacePath, meshInfo.AssetPath).ToString());
			string exportPath = Path.Combine(Path.Combine("Assets", "SP_Textures"), Path.GetFileNameWithoutExtension(meshInfo.AssetPath)).ToString();
			string meshUri = new System.Uri(meshPath).AbsoluteUri;

			JSONClass materialsLink = new JSONClass();
			foreach (Material material in meshInfo.Materials)
			{
				ShaderInfos shaderInfos = ShadersInfos.GetShaderInfos(material.shader);
				JSONClass propertiesAssociation = new JSONClass();
				foreach (string propertyName in shaderInfos.PropertiesAssociation.Keys)
				{
					propertiesAssociation.Add(propertyName, new JSONData(shaderInfos.PropertiesAssociation[propertyName]));
				}

				JSONClass materialLink = new JSONClass();
				materialLink.Add("assetPath", AssetDatabase.GetAssetPath(material));
				materialLink.Add("exportPreset", shaderInfos.ExportPreset);
				materialLink.Add("resourceShader", shaderInfos.ResourceShader);
				materialLink.Add("spToLiveLinkProperties", propertiesAssociation);

				// HACK: Sanitize the name the same way SP internally do it
				string sanitizedName = MaterialsManipulation.SanitizeMaterialName(material.name);
				materialsLink.Add(sanitizedName, materialLink);
			}

			JSONClass project = new JSONClass();
			project.Add("meshUrl", new JSONData(meshUri));
			project.Add("normal", new JSONData("OpenGL"));
			project.Add("template", new JSONData(""));
			project.Add("url", new JSONData(new System.Uri(substancePainterProjectPath).AbsoluteUri));

			JSONClass jsonData = new JSONClass();
			jsonData.Add("applicationName", new JSONData("Unity"));
			jsonData.Add("exportPath", new JSONData(exportPath));
			jsonData.Add("workspacePath", new JSONData(workspacePath));
			jsonData.Add("materials", materialsLink);
			jsonData.Add("project", project);
			jsonData.Add("linkIdentifier", new JSONData(meshInfo.Identifier));

			return jsonData;
		}

		private static void OpenSpProject(MeshInfo meshInfo, string substancePainterProjectPath)
		{
			JSONNode jsonData = GetSpDataLinkToSend(meshInfo, substancePainterProjectPath);
			webSocket.Send(string.Format("{0} {1}", "OPEN_PROJECT", jsonData.ToString()));
		}

		private static void CreateSpProject(MeshInfo meshInfo, string substancePainterProjectPath)
		{
			JSONNode jsonData = GetSpDataLinkToSend(meshInfo, substancePainterProjectPath);
			webSocket.Send(string.Format("{0} {1}", "CREATE_PROJECT", jsonData.ToString()));
		}

		private static void SendMeshToSP(MeshInfo meshInfo)
		{
			if (!webSocket.IsAlive)
			{
				ConnectSocket();
			}
			if (!webSocket.IsAlive || !webSocket.Ping())
			{
				EditorUtility.DisplayDialog(
					"Send to Substance Painter",
					"Substance Painter is not detected.\n" +
					"Please check if Substance Painter is correctly started and if the \"unity-link\" plugin is enabled.", "OK");
				return;
			}

			// Ensure compatibility
			foreach (Material material in meshInfo.Materials)
			{
				if (ShadersInfos.ContainsShader(material.shader))
				{
					ShadersInfos.GetShaderInfos(material.shader).EnsureMaterialCompatibility(material);
				}
			}

			// Check if a project already exist
			string substancePainterProjectPath = GetSpProjectPath(meshInfo);

			if (File.Exists(substancePainterProjectPath))
			{
				// If the project exists, open it then reimport the mesh
				Debug.Log(string.Format("Reopening Substance Painter project located at {0}", substancePainterProjectPath));
				OpenSpProject(meshInfo, substancePainterProjectPath);
			}
			else
			{
				// If the project doesn't exist, create a new one and save it here
				Debug.Log(string.Format("Creating a new Substance Painter project located at {0}", substancePainterProjectPath));
				CreateSpProject(meshInfo, substancePainterProjectPath);
			}
		}

		private static void TryConnectToProject(JSONNode jsonData)
		{
			JSONClass projectInfo = jsonData as JSONClass;
			string projectUrl = new System.Uri(projectInfo["projectUrl"].Value).AbsoluteUri;
			int instanceId = projectInfo["linkIdentifier"].AsInt;

			GameObject gameObject = EditorUtility.InstanceIDToObject(instanceId) as GameObject;
			// Check if the game object exists
			if (!gameObject) return;
			MeshInfo[] meshesInfo = MaterialsManipulation.MeshesInfoFromGameObject(gameObject);

			// Check the game object only matches one mesh info
			if (meshesInfo.Length != 1) return;
			MeshInfo meshInfo = meshesInfo[0];

			// Check that the project url matches
			string substancePainterProjectPath = GetSpProjectPath(meshInfo);
			string gameObjectProjectUrl = new System.Uri(substancePainterProjectPath).AbsoluteUri;
			if (projectUrl != gameObjectProjectUrl) return;

			// If it matches; link both applications
			SendMeshToSP(meshInfo);
		}

		private static void AskForProjectInfo()
		{
			ConnectSocket();
			if (!webSocket.IsAlive || !webSocket.Ping()) return;
			webSocket.Send(string.Format("{0} {1}", "SEND_PROJECT_INFO", "{}"));
		}

		const string SendAssetMenuPath = "Assets/Send to Substance Painter";
		const string SendGameObjectMenuPath = "GameObject/Send to Substance Painter";

		[MenuItem(SendAssetMenuPath)]
		[MenuItem(SendGameObjectMenuPath, false, 20)]
		private static void SendAssetToSP()
		{
			// Get the currently selected mesh game object
			MeshInfo[] meshesInfo = MaterialsManipulation.GetSelectedMeshesInfo();
			switch (meshesInfo.Length)
			{
				case 0:
					EditorUtility.DisplayDialog("Substance Painter",
						"You need to select one compatible mesh game object in the scene hierarchy respecting prerequisites:\n" +
						"- the mesh must be an fbx file imported in project assets\n" +
						"- materials must use the 'Standard' shader\n" +
						"- materials names must be the default ones (as defined in the mesh)", "OK");
					break;
				case 1:
					SendMeshToSP(meshesInfo[0]);
					break;
				default:
					ItemSelectorWindow.ShowSelect(
						"Send to Substance Painter",
						"Select the mesh to send to Substance Painter",
						meshesInfo.ToList().Select(info => info.AssetPath).ToArray(),
						index => SendMeshToSP(meshesInfo[index]));
					break;
			}
		}

		[MenuItem(SendAssetMenuPath, true)]
		// Disable the verification for GameObject menu entry as it doesn't work
		// on game objects contextual menu
		// Instead, pop a dialog to alert on prerequisites to follow
		// [MenuItem(SendGameObjectMenuPath, true)]
		private static bool ValidateSendAssetToSP()
		{
			return MaterialsManipulation.GetSelectedMeshesInfo().Length > 0;
		}
	}
}
