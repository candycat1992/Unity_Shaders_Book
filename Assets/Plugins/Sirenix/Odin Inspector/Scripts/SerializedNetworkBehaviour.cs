//-----------------------------------------------------------------------
// <copyright file="SerializedNetworkBehaviour.cs" company="Sirenix IVS">
// Copyright (c) 2018 Sirenix IVS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>
//-----------------------------------------------------------------------

#if !UNITY_2019_1_OR_NEWER
#pragma warning disable 0618

namespace Sirenix.OdinInspector
{
    using Sirenix.Serialization;
    using UnityEngine;
    using UnityEngine.Networking;

    /// <summary>
    /// A Unity NetworkBehaviour which is serialized by the Sirenix serialization system.
    /// Please note that Odin's custom serialization only works for non-synced variables - [SyncVar] and SyncLists still have the same limitations.
    /// </summary>
    [ShowOdinSerializedPropertiesInInspector]
    public abstract class SerializedNetworkBehaviour : NetworkBehaviour, ISerializationCallbackReceiver, ISupportsPrefabSerialization
    {
        [SerializeField, HideInInspector]
        private SerializationData serializationData;

        SerializationData ISupportsPrefabSerialization.SerializationData { get { return this.serializationData; } set { this.serializationData = value; } }

        void ISerializationCallbackReceiver.OnAfterDeserialize()
        {
            UnitySerializationUtility.DeserializeUnityObject(this, ref this.serializationData);
            this.OnAfterDeserialize();
        }

        void ISerializationCallbackReceiver.OnBeforeSerialize()
        {
            UnitySerializationUtility.SerializeUnityObject(this, ref this.serializationData);
            this.OnBeforeSerialize();
        }

        /// <summary>
        /// Invoked after deserialization has taken place.
        /// </summary>
        protected virtual void OnAfterDeserialize()
        {
        }

        /// <summary>
        /// Invoked before serialization has taken place.
        /// </summary>
        protected virtual void OnBeforeSerialize()
        {
        }

#if UNITY_EDITOR

        [HideInTables]
        [OnInspectorGUI, PropertyOrder(int.MinValue)]
        private void InternalOnInspectorGUI()
        {
            EditorOnlyModeConfigUtility.InternalOnInspectorGUI(this.GetType());
        }

#endif
    }
}

#endif // UNITY_2019_1_OR_NEWER