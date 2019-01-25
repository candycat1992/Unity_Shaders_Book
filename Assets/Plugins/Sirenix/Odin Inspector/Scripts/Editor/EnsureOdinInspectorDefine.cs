﻿#if UNITY_EDITOR
//-----------------------------------------------------------------------
// <copyright file="EnsureOdinInspectorDefine.cs" company="Sirenix IVS">
// Copyright (c) Sirenix IVS. All rights reserved.
// </copyright>
//-----------------------------------------------------------------------
namespace Sirenix.Utilities
{
    using System;
    using System.Linq;
    using UnityEditor;

    /// <summary>
    /// Defines the ODIN_INSPECTOR symbol.
    /// </summary>
    internal static class EnsureOdinInspectorDefine
    {
        private const string DEFINE = "ODIN_INSPECTOR";

        [InitializeOnLoadMethod]
        private static void AssureScriptingDefineSymbol()
        {
            var currentTarget = EditorUserBuildSettings.selectedBuildTargetGroup;

            if (currentTarget == BuildTargetGroup.Unknown)
            {
                return;
            }

            var definesString = PlayerSettings.GetScriptingDefineSymbolsForGroup(currentTarget).Trim();
            var defines = definesString.Split(';');

            if (defines.Contains(DEFINE) == false)
            {
                if (definesString.EndsWith(";", StringComparison.InvariantCulture) == false)
                {
                    definesString += ";";
                }

                definesString += DEFINE;

                PlayerSettings.SetScriptingDefineSymbolsForGroup(currentTarget, definesString);
            }
        }
    }

    //
    // If you have a project where only some users have Odin, and you want to utilize the ODIN_INSPECTOR 
    // define symbol. Then, in order to only define the symbol for those with Odin, you can delete this script, 
    // which prevent ODIN_INSPECTOR from being added to the Unity's player settings.
    // 
    // And instead automatically add the ODIN_INSPECTOR define to an mcs.rsp file if Odin exists using the script below.
    // You can then ignore the mcs.rsp file in source control.
    // 
    // Remember to manually remove the ODIN_INSPECTOR define symbol in player settings after removing this script.
    //
    //    static class AddOdinInspectorDefineIfOdinExist
    //    {
    //        private const string ODIN_MCS_DEFINE = "-define:ODIN_INSPECTOR";
    //
    //        [InitializeOnLoadMethod]
    //        private static void AddOrRemoveOdinDefine()
    //        {
    //            var addDefine = AppDomain.CurrentDomain.GetAssemblies().Any(x => x.FullName.StartsWith("Sirenix.OdinInspector.Editor"));
    //
    // #if ODIN_INSPECTOR
    //            var hasDefine = true;
    // #else
    //            var hasDefine = false;
    // #endif
    //
    //            if (addDefine == hasDefine)
    //            {
    //                return;
    //            }
    //
    //            var mcsPath = Path.Combine(Application.dataPath, "mcs.rsp");
    //            var hasMcsFile = File.Exists(mcsPath);
    //
    //            if (addDefine)
    //            {
    //                var lines = hasMcsFile ? File.ReadAllLines(mcsPath).ToList() : new List<string>();
    //                if (!lines.Any(x => x.Trim() == ODIN_MCS_DEFINE))
    //                {
    //                    lines.Add(ODIN_MCS_DEFINE);
    //                    File.WriteAllLines(mcsPath, lines.ToArray());
    //                    AssetDatabase.Refresh();
    //                }
    //            }
    //            else if (hasMcsFile)
    //            {
    //                var linesWithoutOdinDefine = File.ReadAllLines(mcsPath).Where(x => x.Trim() != ODIN_MCS_DEFINE).ToArray();
    //
    //                if (linesWithoutOdinDefine.Length == 0)
    //                {
    //                    // Optional - Remove the mcs file instead if it doesn't contain any lines.
    //                    File.Delete(mcsPath);
    //                }
    //                else
    //                {
    //                    File.WriteAllLines(mcsPath, linesWithoutOdinDefine);
    //                }
    //
    //                AssetDatabase.Refresh();
    //            }
    //        }
    //    }
}
#endif