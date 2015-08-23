// Copyright (c) 2014 Luminary LLC
// Licensed under The MIT License (See LICENSE for full text)
using UnityEngine;
using System.Collections;

public class SetPropertyAttribute : PropertyAttribute
{
	public string Name { get; private set; }
	public bool IsDirty { get; set; }

	public SetPropertyAttribute(string name)
	{
		this.Name = name;
	}
}
