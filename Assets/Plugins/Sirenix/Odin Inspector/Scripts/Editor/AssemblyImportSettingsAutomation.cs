#if UNITY_5_6_OR_NEWER

//-----------------------------------------------------------------------
// <copyright file="AssemblyImportSettingsAutomation.cs" company="Sirenix IVS">
// Copyright (c) Sirenix IVS. All rights reserved.
// </copyright>
//-----------------------------------------------------------------------

namespace Sirenix.OdinInspector.Editor
{
    using System.IO;
    using Sirenix.Serialization.Utilities.Editor;
    using Sirenix.Utilities;
    using UnityEditor;
    using UnityEditor.Build;

#if UNITY_2018_1_OR_NEWER
    using UnityEditor.Build.Reporting;
#endif
    
    public class AssemblyImportSettingsAutomation :
#if UNITY_2018_1_OR_NEWER
        IPreprocessBuildWithReport
#else
        IPreprocessBuild
#endif
    {
        private const string JITAssemblyFolder = "NoEditor";
        private const string AOTAssemblyFolder = "NoEmitAndNoEditor";

        public int callbackOrder { get { return -1500; } }

        private static void ConfigureImportSettings()
        {   
            if (EditorOnlyModeConfig.Instance.IsEditorOnlyModeEnabled() || ImportSettingsConfig.Instance.AutomateBeforeBuild == false)
            {
                return;
            }

            BuildTarget platform = EditorUserBuildSettings.activeBuildTarget;
            string assemblyDirectory = Path.Combine("Assets", SirenixAssetPaths.SirenixAssembliesPath);
            string[] aotAssemblies = Directory.GetFiles(Path.Combine(assemblyDirectory, AOTAssemblyFolder), "*.dll");
            string[] jitAssemblies = Directory.GetFiles(Path.Combine(assemblyDirectory, JITAssemblyFolder), "*.dll");

            AssetDatabase.StartAssetEditing();
            try
            {
                if (AssemblyImportSettingsUtilities.IsJITSupported(
                    platform,
                    AssemblyImportSettingsUtilities.GetCurrentScriptingBackend(),
                    AssemblyImportSettingsUtilities.GetCurrentApiCompatibilityLevel()))
                {
                    ApplyImportSettings(platform, aotAssemblies, OdinAssemblyImportSettings.ExcludeFromAll);
                    ApplyImportSettings(platform, jitAssemblies, OdinAssemblyImportSettings.IncludeInBuildOnly);
                }
                else
                {
                    ApplyImportSettings(platform, aotAssemblies, OdinAssemblyImportSettings.IncludeInBuildOnly);
                    ApplyImportSettings(platform, jitAssemblies, OdinAssemblyImportSettings.ExcludeFromAll);
                }
            }
            finally
            {
                AssetDatabase.StopAssetEditing();
            }
        }

        private static void ApplyImportSettings(BuildTarget platform, string[] assemblyPaths, OdinAssemblyImportSettings importSettings)
        {
            for (int i = 0; i < assemblyPaths.Length; i++)
            {
                AssemblyImportSettingsUtilities.SetAssemblyImportSettings(platform, assemblyPaths[i], importSettings);
            }
        }

#if UNITY_2018_1_OR_NEWER

        void IPreprocessBuildWithReport.OnPreprocessBuild(BuildReport report)
        {
            ConfigureImportSettings();
        }

#else

        void IPreprocessBuild.OnPreprocessBuild(BuildTarget target, string path)
        {
            ConfigureImportSettings();
        }

#endif
    }
}

#endif // UNITY_5_6_OR_NEWER