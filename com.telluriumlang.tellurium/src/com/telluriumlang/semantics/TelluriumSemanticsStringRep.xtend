package com.telluriumlang.semantics

import org.eclipse.xsemantics.runtime.StringRepresentation

class TelluriumSemanticsStringRep extends StringRepresentation {
	
	def String stringRep(TelluriumBasicType t){
        switch(t){
        	case TelluriumBasicType.BOOLEAN: return "Boolean"
        	case TelluriumBasicType.INT: return "Integer"
        	case TelluriumBasicType.DOUBLE: return "Double"
        	case TelluriumBasicType.STRING: return "String"
        	case TelluriumBasicType.WEB_ELEMENT: return "Web Element",
        	case TelluriumBasicType.WEB_ELEMENT_LIST: return "Web Elements"
        }
        return "Unknown Type"
    }
	
}
