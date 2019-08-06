// Source of the file: http://wiki.unity3d.com/index.php/SimpleJSON
// Added Keys property as following link: http://answers.unity3d.com/comments/649574/view.html

//#define USE_SharpZipLib
#if !UNITY_WEBPLAYER
#define USE_FileIO
#endif
/* * * * *
 * A simple JSON Parser / builder
 * ------------------------------
 *
 * It mainly has been written as a simple JSON parser. It can build a JSON string
 * from the node-tree, or generate a node tree from any valid JSON string.
 *
 * If you want to use compression when saving to file / stream / B64 you have to include
 * SharpZipLib ( http://www.icsharpcode.net/opensource/sharpziplib/ ) in your project and
 * define "USE_SharpZipLib" at the top of the file
 *
 * Written by Bunny83
 * 2012-06-09
 *
 * Modified by oPless, 2014-09-21 to round-trip properly
 *
 * Features / attributes:
 * - provides strongly typed node classes and lists / dictionaries
 * - provides easy access to class members / array items / data values
 * - the parser ignores data types. Each value is a string.
 * - only double quotes (") are used for quoting strings.
 * - values and names are not restricted to quoted strings. They simply add up and are trimmed.
 * - There are only 3 types: arrays(JSONArray), objects(JSONClass) and values(JSONData)
 * - provides "casting" properties to easily convert to / from those types:
 *   int / float / double / bool
 * - provides a common interface for each node so no explicit casting is required.
 * - the parser try to avoid errors, but if malformed JSON is parsed the result is undefined
 *
 *
 * 2012-12-17 Update:
 * - Added internal JSONLazyCreator class which simplifies the construction of a JSON tree
 *   Now you can simple reference any item that doesn't exist yet and it will return a JSONLazyCreator
 *   The class determines the required type by it's further use, creates the type and removes itself.
 * - Added binary serialization / deserialization.
 * - Added support for BZip2 zipped binary format. Requires the SharpZipLib ( http://www.icsharpcode.net/opensource/sharpziplib/ )
 *   The usage of the SharpZipLib library can be disabled by removing or commenting out the USE_SharpZipLib define at the top
 * - The serializer uses different types when it comes to store the values. Since my data values
 *   are all of type string, the serializer will "try" which format fits best. The order is: int, float, double, bool, string.
 *   It's not the most efficient way but for a moderate amount of data it should work on all platforms.
 *
 * * * * */
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace AlgSimpleJSON
{
	public enum JSONBinaryTag
	{
		Array = 1,
		Class = 2,
		Value = 3,
		IntValue = 4,
		DoubleValue = 5,
		BoolValue = 6,
		FloatValue = 7,
	}

	public abstract partial class JSONNode
	{
		#region common interface

		public virtual void Add(string aKey, JSONNode aItem)
		{
		}

		public virtual JSONNode this[int aIndex] { get { return null; } set { } }

		public virtual JSONNode this[string aKey] { get { return null; } set { } }

		public virtual string Value { get { return ""; } set { } }

		public virtual int Count { get { return 0; } }

		public virtual IEnumerable<string> Keys { get { yield break; } }

		public virtual void Add(JSONNode aItem)
		{
			Add("", aItem);
		}

		public virtual JSONNode Remove(string aKey)
		{
			return null;
		}

		public virtual JSONNode Remove(int aIndex)
		{
			return null;
		}

		public virtual JSONNode Remove(JSONNode aNode)
		{
			return aNode;
		}

		public virtual IEnumerable<JSONNode> Children
		{
			get
			{
				yield break;
			}
		}

		public IEnumerable<JSONNode> DeepChildren
		{
			get
			{
				foreach (var C in Children)
					foreach (var D in C.DeepChildren)
						yield return D;
			}
		}

		public override string ToString()
		{
			return "JSONNode";
		}

		public virtual string ToString(string aPrefix)
		{
			return "JSONNode";
		}

		public abstract string ToJSON(int prefix);

		#endregion common interface

		#region typecasting properties

		public virtual JSONBinaryTag Tag { get; set; }

		public virtual int AsInt
		{
			get
			{
				int v = 0;
				if (int.TryParse(Value, out v))
					return v;
				return 0;
			}
			set
			{
				Value = value.ToString();
				Tag = JSONBinaryTag.IntValue;
			}
		}

		public virtual float AsFloat
		{
			get
			{
				float v = 0.0f;
				if (float.TryParse(Value, out v))
					return v;
				return 0.0f;
			}
			set
			{
				Value = value.ToString();
				Tag = JSONBinaryTag.FloatValue;
			}
		}

		public virtual double AsDouble
		{
			get
			{
				double v = 0.0;
				if (double.TryParse(Value, out v))
					return v;
				return 0.0;
			}
			set
			{
				Value = value.ToString();
				Tag = JSONBinaryTag.DoubleValue;

			}
		}

		public virtual bool AsBool
		{
			get
			{
				bool v = false;
				if (bool.TryParse(Value, out v))
					return v;
				return !string.IsNullOrEmpty(Value);
			}
			set
			{
				Value = (value) ? "true" : "false";
				Tag = JSONBinaryTag.BoolValue;

			}
		}

		public virtual JSONArray AsArray
		{
			get
			{
				return this as JSONArray;
			}
		}

		public virtual JSONClass AsObject
		{
			get
			{
				return this as JSONClass;
			}
		}


		#endregion typecasting properties

		#region operators

		public static implicit operator JSONNode(string s)
		{
			return new JSONData(s);
		}

		public static implicit operator string(JSONNode d)
		{
			return (d == null) ? null : d.Value;
		}

		public static bool operator ==(JSONNode a, object b)
		{
			if (b == null && a is JSONLazyCreator)
				return true;
			return System.Object.ReferenceEquals(a, b);
		}

		public static bool operator !=(JSONNode a, object b)
		{
			return !(a == b);
		}

		public override bool Equals(object obj)
		{
			return System.Object.ReferenceEquals(this, obj);
		}

		public override int GetHashCode()
		{
			return base.GetHashCode();
		}

		#endregion operators

		internal static string Escape(string aText)
		{
			string result = "";
			foreach (char c in aText)
			{
				switch (c)
				{
					case '\\':
						result += "\\\\";
						break;
					case '\"':
						result += "\\\"";
						break;
					case '\n':
						result += "\\n";
						break;
					case '\r':
						result += "\\r";
						break;
					case '\t':
						result += "\\t";
						break;
					case '\b':
						result += "\\b";
						break;
					case '\f':
						result += "\\f";
						break;
					default:
						result += c;
						break;
				}
			}
			return result;
		}

		static JSONData Numberize(string token)
		{
			bool flag = false;
			int integer = 0;
			double real = 0;

			if (int.TryParse(token, out integer))
			{
				return new JSONData(integer);
			}

			if (double.TryParse(token, out real))
			{
				return new JSONData(real);
			}

			if (bool.TryParse(token, out flag))
			{
				return new JSONData(flag);
			}

			throw new NotImplementedException(token);
		}

		static void AddElement(JSONNode ctx, string token, string tokenName, bool tokenIsString)
		{
			if (tokenIsString)
			{
				if (ctx is JSONArray)
					ctx.Add(token);
				else
					ctx.Add(tokenName, token); // assume dictionary/object
			}
			else
			{
				JSONData number = Numberize(token);
				if (ctx is JSONArray)
					ctx.Add(number);
				else
					ctx.Add(tokenName, number);

			}
		}

		public static JSONNode Parse(string aJSON)
		{
			Stack<JSONNode> stack = new Stack<JSONNode>();
			JSONNode ctx = null;
			int i = 0;
			StringBuilder Token = new StringBuilder();
			StringBuilder TokenName = new StringBuilder();
			bool QuoteMode = false;
			bool TokenIsString = false;
			while (i < aJSON.Length)
			{
				switch (aJSON[i])
				{
					case '{':
						if (QuoteMode)
						{
							Token.Append(aJSON[i]);
							break;
						}
						stack.Push(new JSONClass());
						if (ctx != null)
						{
							string tmpName = TokenName.ToString().Trim();
							if (ctx is JSONArray)
								ctx.Add(stack.Peek());
							else if (tmpName != "")
								ctx.Add(tmpName, stack.Peek());
						}
						TokenName.Length = 0;
						Token.Length = 0;
						ctx = stack.Peek();
						break;

					case '[':
						if (QuoteMode)
						{
							Token.Append(aJSON[i]);
							break;
						}

						stack.Push(new JSONArray());
						if (ctx != null)
						{
							string tmpName = TokenName.ToString().Trim();
							if (ctx is JSONArray)
								ctx.Add(stack.Peek());
							else if (tmpName != "")
								ctx.Add(tmpName, stack.Peek());
						}
						TokenName.Length = 0;
						Token.Length = 0;
						ctx = stack.Peek();
						break;

					case '}':
					case ']':
						if (QuoteMode)
						{

							Token.Append(aJSON[i]);
							break;
						}
						if (stack.Count == 0)
							throw new Exception("JSON Parse: Too many closing brackets");

						stack.Pop();
						if (Token.Length > 0)
						{
							AddElement(ctx, Token.ToString(), TokenName.ToString(), TokenIsString);
							TokenIsString = false;
						}
						TokenName.Length = 0;
						Token.Length = 0;
						if (stack.Count > 0)
							ctx = stack.Peek();
						break;

					case ':':
						if (QuoteMode)
						{
							Token.Append(aJSON[i]);
							break;
						}
						TokenName.Length = 0;
						TokenName.Append(Token);
						Token.Length = 0;
						TokenIsString = false;
						break;

					case '"':
						QuoteMode ^= true;
						TokenIsString = QuoteMode == true ? true : TokenIsString;
						break;

					case ',':
						if (QuoteMode)
						{
							Token.Append(aJSON[i]);
							break;
						}
						if (Token.Length > 0)
						{
							AddElement(ctx, Token.ToString(), TokenName.ToString(), TokenIsString);
							TokenIsString = false;
						}
						TokenName.Length = 0;
						Token.Length = 0;
						TokenIsString = false;
						break;

					case '\r':
					case '\n':
						break;

					case ' ':
					case '\t':
						if (QuoteMode)
							Token.Append(aJSON[i]);
						break;

					case '\\':
						++i;
						if (QuoteMode)
						{
							char C = aJSON[i];
							switch (C)
							{
								case 't':
									Token.Append('\t');
									break;
								case 'r':
									Token.Append('\r');
									break;
								case 'n':
									Token.Append('\n');
									break;
								case 'b':
									Token.Append('\b');
									break;
								case 'f':
									Token.Append('\f');
									break;
								case 'u':
									{
										string s = aJSON.Substring(i + 1, 4);
										Token.Append((char)int.Parse(
											s,
											System.Globalization.NumberStyles.AllowHexSpecifier));
										i += 4;
										break;
									}
								default:
									Token.Append(C);
									break;
							}
						}
						break;

					default:
						Token.Append(aJSON[i]);
						break;
				}
				++i;
			}
			if (QuoteMode)
			{
				throw new Exception("JSON Parse: Quotation marks seems to be messed up.");
			}
			return ctx;
		}

		public virtual void Serialize(System.IO.BinaryWriter aWriter)
		{
		}

		public void SaveToStream(System.IO.Stream aData)
		{
			var W = new System.IO.BinaryWriter(aData);
			Serialize(W);
		}

#if USE_SharpZipLib
		public void SaveToCompressedStream(System.IO.Stream aData)
		{
			using (var gzipOut = new ICSharpCode.SharpZipLib.BZip2.BZip2OutputStream(aData))
			{
				gzipOut.IsStreamOwner = false;
				SaveToStream(gzipOut);
				gzipOut.Close();
			}
		}

		public void SaveToCompressedFile(string aFileName)
		{

#if USE_FileIO
			System.IO.Directory.CreateDirectory((new System.IO.FileInfo(aFileName)).Directory.FullName);
			using(var F = System.IO.File.OpenWrite(aFileName))
			{
				SaveToCompressedStream(F);
			}

#else
			throw new Exception("Can't use File IO stuff in webplayer");
#endif
		}
		public string SaveToCompressedBase64()
		{
			using (var stream = new System.IO.MemoryStream())
			{
				SaveToCompressedStream(stream);
				stream.Position = 0;
				return System.Convert.ToBase64String(stream.ToArray());
			}
		}

#else
		public void SaveToCompressedStream(System.IO.Stream aData)
		{
			throw new Exception("Can't use compressed functions. You need include the SharpZipLib and uncomment the define at the top of SimpleJSON");
		}

		public void SaveToCompressedFile(string aFileName)
		{
			throw new Exception("Can't use compressed functions. You need include the SharpZipLib and uncomment the define at the top of SimpleJSON");
		}

		public string SaveToCompressedBase64()
		{
			throw new Exception("Can't use compressed functions. You need include the SharpZipLib and uncomment the define at the top of SimpleJSON");
		}
#endif

		public void SaveToFile(string aFileName)
		{
#if USE_FileIO
			System.IO.Directory.CreateDirectory((new System.IO.FileInfo(aFileName)).Directory.FullName);
			using (var F = System.IO.File.OpenWrite(aFileName))
			{
				SaveToStream(F);
			}
#else
			throw new Exception ("Can't use File IO stuff in webplayer");
#endif
		}

		public string SaveToBase64()
		{
			using (var stream = new System.IO.MemoryStream())
			{
				SaveToStream(stream);
				stream.Position = 0;
				return System.Convert.ToBase64String(stream.ToArray());
			}
		}

		public static JSONNode Deserialize(System.IO.BinaryReader aReader)
		{
			JSONBinaryTag type = (JSONBinaryTag)aReader.ReadByte();
			switch (type)
			{
				case JSONBinaryTag.Array:
					{
						int count = aReader.ReadInt32();
						JSONArray tmp = new JSONArray();
						for (int i = 0; i < count; i++)
							tmp.Add(Deserialize(aReader));
						return tmp;
					}
				case JSONBinaryTag.Class:
					{
						int count = aReader.ReadInt32();
						JSONClass tmp = new JSONClass();
						for (int i = 0; i < count; i++)
						{
							string key = aReader.ReadString();
							var val = Deserialize(aReader);
							tmp.Add(key, val);
						}
						return tmp;
					}
				case JSONBinaryTag.Value:
					{
						return new JSONData(aReader.ReadString());
					}
				case JSONBinaryTag.IntValue:
					{
						return new JSONData(aReader.ReadInt32());
					}
				case JSONBinaryTag.DoubleValue:
					{
						return new JSONData(aReader.ReadDouble());
					}
				case JSONBinaryTag.BoolValue:
					{
						return new JSONData(aReader.ReadBoolean());
					}
				case JSONBinaryTag.FloatValue:
					{
						return new JSONData(aReader.ReadSingle());
					}

				default:
					{
						throw new Exception("Error deserializing JSON. Unknown tag: " + type);
					}
			}
		}

#if USE_SharpZipLib
		public static JSONNode LoadFromCompressedStream(System.IO.Stream aData)
		{
			var zin = new ICSharpCode.SharpZipLib.BZip2.BZip2InputStream(aData);
			return LoadFromStream(zin);
		}
		public static JSONNode LoadFromCompressedFile(string aFileName)
		{
#if USE_FileIO
			using(var F = System.IO.File.OpenRead(aFileName))
			{
				return LoadFromCompressedStream(F);
			}
#else
			throw new Exception("Can't use File IO stuff in webplayer");
#endif
		}
		public static JSONNode LoadFromCompressedBase64(string aBase64)
		{
			var tmp = System.Convert.FromBase64String(aBase64);
			var stream = new System.IO.MemoryStream(tmp);
			stream.Position = 0;
			return LoadFromCompressedStream(stream);
		}
#else
		public static JSONNode LoadFromCompressedFile(string aFileName)
		{
			throw new Exception("Can't use compressed functions. You need include the SharpZipLib and uncomment the define at the top of SimpleJSON");
		}

		public static JSONNode LoadFromCompressedStream(System.IO.Stream aData)
		{
			throw new Exception("Can't use compressed functions. You need include the SharpZipLib and uncomment the define at the top of SimpleJSON");
		}

		public static JSONNode LoadFromCompressedBase64(string aBase64)
		{
			throw new Exception("Can't use compressed functions. You need include the SharpZipLib and uncomment the define at the top of SimpleJSON");
		}
#endif

		public static JSONNode LoadFromStream(System.IO.Stream aData)
		{
			using (var R = new System.IO.BinaryReader(aData))
			{
				return Deserialize(R);
			}
		}

		public static JSONNode LoadFromFile(string aFileName)
		{
#if USE_FileIO
			using (var F = System.IO.File.OpenRead(aFileName))
			{
				return LoadFromStream(F);
			}
#else
			throw new Exception ("Can't use File IO stuff in webplayer");
#endif
		}

		public static JSONNode LoadFromBase64(string aBase64)
		{
			var tmp = System.Convert.FromBase64String(aBase64);
			var stream = new System.IO.MemoryStream(tmp);
			stream.Position = 0;
			return LoadFromStream(stream);
		}
	}
	// End of JSONNode

	public class JSONArray : JSONNode, IEnumerable
	{
		private List<JSONNode> m_List = new List<JSONNode>();

		public override JSONNode this[int aIndex]
		{
			get
			{
				if (aIndex < 0 || aIndex >= m_List.Count)
					return new JSONLazyCreator(this);
				return m_List[aIndex];
			}
			set
			{
				if (aIndex < 0 || aIndex >= m_List.Count)
					m_List.Add(value);
				else
					m_List[aIndex] = value;
			}
		}

		public override JSONNode this[string aKey]
		{
			get { return new JSONLazyCreator(this); }
			set { m_List.Add(value); }
		}

		public override int Count
		{
			get { return m_List.Count; }
		}


		public override void Add(string aKey, JSONNode aItem)
		{
			m_List.Add(aItem);
		}

		public override JSONNode Remove(int aIndex)
		{
			if (aIndex < 0 || aIndex >= m_List.Count)
				return null;
			JSONNode tmp = m_List[aIndex];
			m_List.RemoveAt(aIndex);
			return tmp;
		}

		public override JSONNode Remove(JSONNode aNode)
		{
			m_List.Remove(aNode);
			return aNode;
		}

		public override IEnumerable<JSONNode> Children
		{
			get
			{
				foreach (JSONNode N in m_List)
					yield return N;
			}
		}

		public IEnumerator GetEnumerator()
		{
			foreach (JSONNode N in m_List)
				yield return N;
		}

		public override string ToString()
		{
			string result = "[ ";
			foreach (JSONNode N in m_List)
			{
				if (result.Length > 2)
					result += ", ";
				result += N.ToString();
			}
			result += " ]";
			return result;
		}

		public override string ToString(string aPrefix)
		{
			string result = "[ ";
			foreach (JSONNode N in m_List)
			{
				if (result.Length > 3)
					result += ", ";
				result += "\n" + aPrefix + "   ";
				result += N.ToString(aPrefix + "   ");
			}
			result += "\n" + aPrefix + "]";
			return result;
		}

		public override string ToJSON(int prefix)
		{
			string s = new string(' ', (prefix + 1) * 2);
			string ret = "[ ";
			foreach (JSONNode n in m_List)
			{
				if (ret.Length > 3)
					ret += ", ";
				ret += "\n" + s;
				ret += n.ToJSON(prefix + 1);

			}
			ret += "\n" + s + "]";
			return ret;
		}

		public override void Serialize(System.IO.BinaryWriter aWriter)
		{
			aWriter.Write((byte)JSONBinaryTag.Array);
			aWriter.Write(m_List.Count);
			for (int i = 0; i < m_List.Count; i++)
			{
				m_List[i].Serialize(aWriter);
			}
		}
	}
	// End of JSONArray

	public class JSONClass : JSONNode, IEnumerable
	{
		private Dictionary<string, JSONNode> m_Dict = new Dictionary<string, JSONNode>();

		public override JSONNode this[string aKey]
		{
			get
			{
				if (m_Dict.ContainsKey(aKey))
					return m_Dict[aKey];
				else
					return new JSONLazyCreator(this, aKey);
			}
			set
			{
				if (m_Dict.ContainsKey(aKey))
					m_Dict[aKey] = value;
				else
					m_Dict.Add(aKey, value);
			}
		}

		public override JSONNode this[int aIndex]
		{
			get
			{
				if (aIndex < 0 || aIndex >= m_Dict.Count)
					return null;
				return m_Dict.ElementAt(aIndex).Value;
			}
			set
			{
				if (aIndex < 0 || aIndex >= m_Dict.Count)
					return;
				string key = m_Dict.ElementAt(aIndex).Key;
				m_Dict[key] = value;
			}
		}

		public override int Count
		{
			get { return m_Dict.Count; }
		}

		public override IEnumerable<string> Keys
		{
			get
			{
				foreach (var key in m_Dict.Keys)
					yield return key;
			}
		}

		public override void Add(string aKey, JSONNode aItem)
		{
			if (!string.IsNullOrEmpty(aKey))
			{
				if (m_Dict.ContainsKey(aKey))
					m_Dict[aKey] = aItem;
				else
					m_Dict.Add(aKey, aItem);
			}
			else
				m_Dict.Add(Guid.NewGuid().ToString(), aItem);
		}

		public override JSONNode Remove(string aKey)
		{
			if (!m_Dict.ContainsKey(aKey))
				return null;
			JSONNode tmp = m_Dict[aKey];
			m_Dict.Remove(aKey);
			return tmp;
		}

		public override JSONNode Remove(int aIndex)
		{
			if (aIndex < 0 || aIndex >= m_Dict.Count)
				return null;
			var item = m_Dict.ElementAt(aIndex);
			m_Dict.Remove(item.Key);
			return item.Value;
		}

		public override JSONNode Remove(JSONNode aNode)
		{
			try
			{
				var item = m_Dict.Where(k => k.Value == aNode).First();
				m_Dict.Remove(item.Key);
				return aNode;
			}
			catch
			{
				return null;
			}
		}

		public override IEnumerable<JSONNode> Children
		{
			get
			{
				foreach (KeyValuePair<string, JSONNode> N in m_Dict)
					yield return N.Value;
			}
		}

		public IEnumerator GetEnumerator()
		{
			foreach (KeyValuePair<string, JSONNode> N in m_Dict)
				yield return N;
		}

		public override string ToString()
		{
			string result = "{";
			foreach (KeyValuePair<string, JSONNode> N in m_Dict)
			{
				if (result.Length > 2)
					result += ", ";
				result += "\"" + Escape(N.Key) + "\":" + N.Value.ToString();
			}
			result += "}";
			return result;
		}

		public override string ToString(string aPrefix)
		{
			string result = "{ ";
			foreach (KeyValuePair<string, JSONNode> N in m_Dict)
			{
				if (result.Length > 3)
					result += ", ";
				result += "\n" + aPrefix + "   ";
				result += "\"" + Escape(N.Key) + "\" : " + N.Value.ToString(aPrefix + "   ");
			}
			result += "\n" + aPrefix + "}";
			return result;
		}

		public override string ToJSON(int prefix)
		{
			string s = new string(' ', (prefix + 1) * 2);
			string ret = "{ ";
			foreach (KeyValuePair<string, JSONNode> n in m_Dict)
			{
				if (ret.Length > 3)
					ret += ", ";
				ret += "\n" + s;
				ret += string.Format("\"{0}\": {1}", n.Key, n.Value.ToJSON(prefix + 1));
			}
			ret += "\n" + s + "}";
			return ret;
		}

		public override void Serialize(System.IO.BinaryWriter aWriter)
		{
			aWriter.Write((byte)JSONBinaryTag.Class);
			aWriter.Write(m_Dict.Count);
			foreach (string K in m_Dict.Keys)
			{
				aWriter.Write(K);
				m_Dict[K].Serialize(aWriter);
			}
		}
	}
	// End of JSONClass

	public class JSONData : JSONNode
	{
		private string m_Data;


		public override string Value
		{
			get { return m_Data; }
			set
			{
				m_Data = value;
				Tag = JSONBinaryTag.Value;
			}
		}

		public JSONData(string aData)
		{
			m_Data = aData;
			Tag = JSONBinaryTag.Value;
		}

		public JSONData(float aData)
		{
			AsFloat = aData;
		}

		public JSONData(double aData)
		{
			AsDouble = aData;
		}

		public JSONData(bool aData)
		{
			AsBool = aData;
		}

		public JSONData(int aData)
		{
			AsInt = aData;
		}

		public override string ToString()
		{
			return "\"" + Escape(m_Data) + "\"";
		}

		public override string ToString(string aPrefix)
		{
			return "\"" + Escape(m_Data) + "\"";
		}

		public override string ToJSON(int prefix)
		{
			switch (Tag)
			{
				case JSONBinaryTag.DoubleValue:
				case JSONBinaryTag.FloatValue:
				case JSONBinaryTag.IntValue:
					return m_Data;
				case JSONBinaryTag.Value:
					return string.Format("\"{0}\"", Escape(m_Data));
				default:
					throw new NotSupportedException("This shouldn't be here: " + Tag.ToString());
			}
		}

		public override void Serialize(System.IO.BinaryWriter aWriter)
		{
			var tmp = new JSONData("");

			tmp.AsInt = AsInt;
			if (tmp.m_Data == this.m_Data)
			{
				aWriter.Write((byte)JSONBinaryTag.IntValue);
				aWriter.Write(AsInt);
				return;
			}
			tmp.AsFloat = AsFloat;
			if (tmp.m_Data == this.m_Data)
			{
				aWriter.Write((byte)JSONBinaryTag.FloatValue);
				aWriter.Write(AsFloat);
				return;
			}
			tmp.AsDouble = AsDouble;
			if (tmp.m_Data == this.m_Data)
			{
				aWriter.Write((byte)JSONBinaryTag.DoubleValue);
				aWriter.Write(AsDouble);
				return;
			}

			tmp.AsBool = AsBool;
			if (tmp.m_Data == this.m_Data)
			{
				aWriter.Write((byte)JSONBinaryTag.BoolValue);
				aWriter.Write(AsBool);
				return;
			}
			aWriter.Write((byte)JSONBinaryTag.Value);
			aWriter.Write(m_Data);
		}
	}
	// End of JSONData

	internal class JSONLazyCreator : JSONNode
	{
		private JSONNode m_Node = null;
		private string m_Key = null;

		public JSONLazyCreator(JSONNode aNode)
		{
			m_Node = aNode;
			m_Key = null;
		}

		public JSONLazyCreator(JSONNode aNode, string aKey)
		{
			m_Node = aNode;
			m_Key = aKey;
		}

		private void Set(JSONNode aVal)
		{
			if (m_Key == null)
			{
				m_Node.Add(aVal);
			}
			else
			{
				m_Node.Add(m_Key, aVal);
			}
			m_Node = null; // Be GC friendly.
		}

		public override JSONNode this[int aIndex]
		{
			get
			{
				return new JSONLazyCreator(this);
			}
			set
			{
				var tmp = new JSONArray();
				tmp.Add(value);
				Set(tmp);
			}
		}

		public override JSONNode this[string aKey]
		{
			get
			{
				return new JSONLazyCreator(this, aKey);
			}
			set
			{
				var tmp = new JSONClass();
				tmp.Add(aKey, value);
				Set(tmp);
			}
		}

		public override void Add(JSONNode aItem)
		{
			var tmp = new JSONArray();
			tmp.Add(aItem);
			Set(tmp);
		}

		public override void Add(string aKey, JSONNode aItem)
		{
			var tmp = new JSONClass();
			tmp.Add(aKey, aItem);
			Set(tmp);
		}

		public static bool operator ==(JSONLazyCreator a, object b)
		{
			if (b == null)
				return true;
			return System.Object.ReferenceEquals(a, b);
		}

		public static bool operator !=(JSONLazyCreator a, object b)
		{
			return !(a == b);
		}

		public override bool Equals(object obj)
		{
			if (obj == null)
				return true;
			return System.Object.ReferenceEquals(this, obj);
		}

		public override int GetHashCode()
		{
			return base.GetHashCode();
		}

		public override string ToString()
		{
			return "";
		}

		public override string ToString(string aPrefix)
		{
			return "";
		}

		public override string ToJSON(int prefix)
		{
			return "";
		}

		public override int AsInt
		{
			get
			{
				JSONData tmp = new JSONData(0);
				Set(tmp);
				return 0;
			}
			set
			{
				JSONData tmp = new JSONData(value);
				Set(tmp);
			}
		}

		public override float AsFloat
		{
			get
			{
				JSONData tmp = new JSONData(0.0f);
				Set(tmp);
				return 0.0f;
			}
			set
			{
				JSONData tmp = new JSONData(value);
				Set(tmp);
			}
		}

		public override double AsDouble
		{
			get
			{
				JSONData tmp = new JSONData(0.0);
				Set(tmp);
				return 0.0;
			}
			set
			{
				JSONData tmp = new JSONData(value);
				Set(tmp);
			}
		}

		public override bool AsBool
		{
			get
			{
				JSONData tmp = new JSONData(false);
				Set(tmp);
				return false;
			}
			set
			{
				JSONData tmp = new JSONData(value);
				Set(tmp);
			}
		}

		public override JSONArray AsArray
		{
			get
			{
				JSONArray tmp = new JSONArray();
				Set(tmp);
				return tmp;
			}
		}

		public override JSONClass AsObject
		{
			get
			{
				JSONClass tmp = new JSONClass();
				Set(tmp);
				return tmp;
			}
		}
	}
	// End of JSONLazyCreator

	public static class JSON
	{
		public static JSONNode Parse(string aJSON)
		{
			return JSONNode.Parse(aJSON);
		}
	}
}
