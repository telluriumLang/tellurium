package com.telluriumlang.generator

import com.telluriumlang.tellurium.ElementExpressions
import com.telluriumlang.tellurium.FindElement
import com.telluriumlang.tellurium.FindElements
import com.telluriumlang.tellurium.ExtractElementFromList
import com.telluriumlang.tellurium.ElementsSelectorExpr
import com.telluriumlang.tellurium.ElementsSelectorRef
import org.eclipse.emf.ecore.EObject

class ElementSelectorGenerator {
	
	
	def static String generateDeclaration(ElementExpressions exp, String varName, TelluriumGeneratorContext ctx){
		if(!ctx.importList.contains("org.openqa.selenium.WebElement")) {
	    	ctx.importList.add("org.openqa.selenium.WebElement");
	    }
		if(exp instanceof FindElement){
			return '''«exp.inferElementType» «varName» = «exp.generateSelector(ctx)»'''
		}else{
			 if (!ctx.importList.contains("java.util.List")) {
		        ctx.importList.add("java.util.List");
		    }
		    return '''«exp.inferElementType» «varName» = «exp.generateSelector(ctx)»'''
		}
	}
	
	def static String generateDeclaration(ExtractElementFromList efl, String varName, String index, TelluriumGeneratorContext ctx){
		if(!ctx.importList.contains("org.openqa.selenium.WebElement")) {
	    	ctx.importList.add("org.openqa.selenium.WebElement");
	    }
		return '''«efl.inferElementType» «varName» = «efl.generateExtractor».get(«index»)'''
	}
	
	def static String generateSelector(ElementExpressions exp, TelluriumGeneratorContext ctx){
		if(!ctx.importList.contains("org.openqa.selenium.By")) {
	        ctx.importList.add("org.openqa.selenium.By");
	    }
	    return exp.doGenerate
	}
	
	def static String generateExtractor(ExtractElementFromList efl)'''«efl.operation.doGenerate»'''
	
	def static String inferElementType(EObject obj){
		if(obj instanceof ExtractElementFromList){
			return "WebElement"
		}else if(obj instanceof ElementExpressions){
			if(obj instanceof FindElement){
				return "WebElement"
			}else{
				return "List<WebElement>"
			}
		}else {
			return "Object"
		}
	}
	
	def static dispatch String doGenerate(FindElement exp)'''driver.findElement(«exp.selector.inferSelector»)'''
	
	def static dispatch String doGenerate(FindElements exp)'''driver.findElements(«exp.selector.inferSelector»)'''
	
	def static dispatch String doGenerate(ElementsSelectorExpr esExpr)'''«esExpr.elements.doGenerate»'''
	
	def static dispatch String doGenerate(ElementsSelectorRef esRef)'''«esRef.ref.name»'''
	
	/** Try to infer the selector, based on: 
	 * <ul>
	 * <li> https://www.w3.org/TR/html401/types.html#type-cdata</li>
	 * <li> https://www.w3.org/TR/selectors-3/</li>
	 */
	def static String inferSelector(String userInput){
		var selector = userInput.trim().replaceAll("\"", "\\\\\"");
		if(selector.startsWith("#") && selector.matches("^#[a-zA-Z][a-zA-Z0-9_:\\.\\-]*$") ){
			return 'By.id("'+selector.substring(1)+'")';
		}else if(selector.startsWith(".") && selector.matches("^\\.[a-zA-Z][a-zA-Z0-9_:.\\-]*$") ){
			return 'By.className("'+selector.substring(1)+'")';
		}else if(selector.startsWith("name") && selector.matches("^name\\s*=\\s*'[a-zA-Z0-9_:.\\-\\s]*'$") ){
			var name = selector.replaceAll("^name\\s*=\\s*'","");
			return 'By.name("'+name.substring(0,name.length - 1)+'")';
		}else if(selector.matches("^[a-zA-Z][a-zA-Z0-9_:.\\-]*$")){
			return 'By.tagName("'+selector+'")';
		}else if(selector.startsWith("/")){
			return 'By.xpath("'+selector+'")';
		}
		return 'By.cssSelector("'+selector+'")'
	}
}
