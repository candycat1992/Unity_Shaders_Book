using System;
using UnityEditor;
using UnityEngine;

namespace Alg
{
	public class ItemSelectorWindow : EditorWindow
	{
		public event EventHandler<EntrySelectedEventArgs> EntrySelected;

		private string _description;
		private string[] _entries;

		public static void ShowSelect(string title, string description, string[] entries, Action<int> callback)
		{
			ItemSelectorWindow window = EditorWindow.GetWindow(typeof(ItemSelectorWindow), true, title) as ItemSelectorWindow;
			window._description = description;
			window._entries = entries;
			window.EntrySelected += (o, e) => callback(e.Index);
			window.ShowPopup();
		}

		void OnGUI()
		{
			GUILayout.Label(_description);
			for (int i = 0; i < _entries.Length; ++i)
			{
				if (GUILayout.Button(_entries[i]))
				{
					OnEntrySelected(new EntrySelectedEventArgs() { Index = i });
					Close();
				}
			}
			EditorGUILayout.Space();
			if (GUILayout.Button("Cancel"))
			{
				Close();
			}
		}

		private void OnEntrySelected(EntrySelectedEventArgs e)
		{
			EventHandler<EntrySelectedEventArgs> handler = EntrySelected;
			if (handler != null)
			{
				handler(this, e);
			}
		}

		public class EntrySelectedEventArgs : EventArgs
		{
			public int Index { get; set; }
		}
	}
}
