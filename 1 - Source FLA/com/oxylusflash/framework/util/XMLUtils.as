package com.oxylusflash.framework.util
{
	/**
	 * XML util
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class XMLUtils
	{
		
		public function XMLUtils()
		{
			throw new Error("XMLUtils class has static methods. No need for instatiation.");
		}
		
		/**
		 * Converts a XML block to an object
		 * @param	xml			XML block
		 * @param	recursive 	Parse children as well
		 * @return	Object equivalent
		 */
		public static function toObject(xml:XML, recursive:Boolean = true):Object
		{
			var nodes:XMLList = xml.children();
			var attributes:XMLList;
			var nodeName:String;
			var node:XML;
			var firstNode:XML;
			var result:Object = { };
			
			for each(node in nodes)
			{
				nodeName = String(node.name());
				firstNode = node.children()[0];
				
				if (firstNode)
				{
					switch(firstNode.nodeKind())
					{
						case "text": result[nodeName] = StringUtil.parse(String(node.text())); break;
						case "element": if (recursive) result[nodeName] = toObject(node, true); break;
					}
				}
				
				attributes = node.attributes();
				for each(node in attributes)
				{
					result[nodeName + "_" + String(node.name())] = StringUtil.parse(String(node[0]));
				}
			}
			
			return result;
		}
	}

}
