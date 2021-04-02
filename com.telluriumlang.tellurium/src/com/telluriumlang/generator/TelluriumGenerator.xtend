/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import com.telluriumlang.tellurium.AutomationTestSet
import com.telluriumlang.tellurium.TestCase
import com.telluriumlang.tellurium.DriverImplicityWait
import com.telluriumlang.tellurium.SimpleKeyboardInput
import com.telluriumlang.tellurium.ComplexKeyboardInput
import com.telluriumlang.tellurium.KeyboardInput
import com.telluriumlang.tellurium.ModifierKey
import com.telluriumlang.tellurium.MouseAction
import com.telluriumlang.tellurium.MouseInput
import com.telluriumlang.tellurium.OpenPage

/**
 * Generates code from the Tellurium model on save.
 */
class TelluriumGenerator extends AbstractGenerator {
	
	val String BLANK_LINE = "\n\n";

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		var ctx = loadCtx(resource);
		var filePath = ctx.packageName.replaceAll("\\.","/") 
		filePath = filePath + "/" + ctx.className + ".java"
		val model = resource.contents.head as AutomationTestSet;
		try{
			var packageName = "";
			if(!ctx.packageName.empty){
				packageName = "package " + ctx.packageName + ";";
			}
			var sourecode = model.generateProgram(ctx);
			var importCode = generateImportCode(model,ctx);
			fsa.generateFile(filePath,packageName + BLANK_LINE + importCode + BLANK_LINE + sourecode + BLANK_LINE);
		}catch(Exception ex){
			ex.printStackTrace
		}
	}
	
	def generateImportCode(AutomationTestSet ats, TelluriumGeneratorContext ctx){
		var importCode = "";
		if(ats.testConfig.filter[t | t instanceof DriverImplicityWait].size > 0){
			importCode += "import java.util.concurrent.TimeUnit;" + BLANK_LINE;
		}
		importCode += ctx.importList.map[ importPackage | 
				'import ' + importPackage + ';'
		].join('\n');
		return importCode;
	}
	
	def TelluriumGeneratorContext loadCtx(Resource resource){
		var ctx = new TelluriumGeneratorContext();
		var teFileName = resource.URI.segments.last;
		var pathSegments = resource.URI.segments;
		var packageName = new StringBuffer();
		var startConcat = false;
		for(var i = 0; i < pathSegments.length - 1 ; i ++ ){
			if(startConcat){
				if(packageName.length > 0){
					packageName.append(".");
				}
				packageName.append(pathSegments.get(i));
			}
			if(!startConcat && pathSegments.get(i) == "src"){
				startConcat = true;
			}
		}
		ctx.className = teFileName.replace(".te","").toFirstUpper;
		ctx.packageName = packageName.toString;
		return ctx;
	}
	
	def dispatch String generateProgram(AutomationTestSet ats, TelluriumGeneratorContext ctx)'''	
	public class «ctx.className» {
		
		«new TestConfigurationGenerator().generateProgram(ats,ctx)»
		
		«ats.testcases.map[generateProgram(ctx)].join('\n')»
	
	}
	'''
	
	def dispatch String generateProgram(TestCase ats, TelluriumGeneratorContext ctx)'''
	@Test
	public void «ats.name»() {
		«ats.statements.map[generateProgram(ctx)].join('\n')»
	}
	'''
	
	def dispatch String generateProgram(SimpleKeyboardInput ski, TelluriumGeneratorContext ctx)'''
	«if(ski.target!==null){'''//target:«ski.target»'''}»
	//.sendKeys("«ski.keySequence»");
	new Actions(driver).sendKeys("«ski.keySequence»").build().perform();
	'''
	
	def dispatch String generateProgram(ComplexKeyboardInput cki, TelluriumGeneratorContext ctx){
		if(!ctx.importList.exists[im | im === "org.openqa.selenium.Keys"]){
			ctx.importList+="org.openqa.selenium.Keys"
		}
	'''
	«if(cki.target!==null){'''//target:«cki.target»'''}»
	//.keyDown(Keys.«cki.modifier.interpretModifier»).sendKeys("«cki.keySequence»").keyUp(Keys.«cki.modifier.interpretModifier»);
	new Actions(driver).keyDown(Keys.«cki.modifier.interpretModifier»).sendKeys("«cki.keySequence»").keyUp(Keys.«cki.modifier.interpretModifier»).build().perform();
	'''
	}
	
	def interpretModifier(ModifierKey k){
		switch k {
			case ModifierKey::SHIFT : '''SHIFT'''
			case ModifierKey::ALT : '''ALT'''
			case ModifierKey::CTRL : '''CONTROL'''
			case ModifierKey::META : '''META'''
			case ModifierKey::WIN : '''META'''
			
		}
	}
	
	def dispatch String generateProgram(MouseInput mi, TelluriumGeneratorContext ctx)'''
	«if(mi.target!==null){'''//target:«mi.target»'''}»
	new Actions(driver).«mi.MAction.interpretMouseAction»().build().perform();
	'''
	
	
	def interpretMouseAction(MouseAction ma){
		switch ma {
			case MouseAction::CLICK : '''click'''
			case MouseAction::DOUBLE_CLICK : '''doubleClick'''
			case MouseAction::CLICK_AND_HOLD : '''clickAndHold'''
			case MouseAction::RIGHT_CLICK : '''contextClick'''
			case MouseAction::RELEASE : '''release'''
			
		}
	}
	
	def dispatch String generateProgram(OpenPage openPage, TelluriumGeneratorContext ctx)'''
	driver.get("«openPage.target»");
	'''
}

