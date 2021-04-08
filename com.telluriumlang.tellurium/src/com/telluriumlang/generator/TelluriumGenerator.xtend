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
import com.telluriumlang.tellurium.QuitAndClose
import com.telluriumlang.tellurium.Navigate
import com.telluriumlang.tellurium.QuitAndCloseAction
import com.telluriumlang.tellurium.Window
import com.telluriumlang.tellurium.CookieAdd
import com.telluriumlang.tellurium.CookieDelete
import com.telluriumlang.tellurium.Cookie
import com.telluriumlang.tellurium.VariableDeclaration
import com.telluriumlang.tellurium.DoubleLitera
import com.telluriumlang.tellurium.IntLitera
import com.telluriumlang.tellurium.StringLitera
import com.telluriumlang.tellurium.Variables
import com.telluriumlang.tellurium.VarExpression
import com.telluriumlang.tellurium.ElementExpressions
import com.telluriumlang.tellurium.ExtractElementFromList
import com.telluriumlang.tellurium.ElementReferences
import com.telluriumlang.tellurium.LocateElement
import com.telluriumlang.tellurium.ElementReference
import com.telluriumlang.tellurium.ExtractEleFromListRef
import com.telluriumlang.tellurium.AssertStatement

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
			var finalCode = packageName + BLANK_LINE + importCode + BLANK_LINE + sourecode + BLANK_LINE;
			fsa.generateFile(filePath,finalCode.trim);
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
		«ats.statements.map[generateProgram(ctx).trim].join('\n')»
	}
	'''
	
	def dispatch String generateProgram(QuitAndClose qandc, TelluriumGeneratorContext ctx)'''
	«IF qandc.action == QuitAndCloseAction.CLOSE »
	driver.close();
	«ELSE»
	driver.quit();
	driver = null;
	«ENDIF»
	'''
	
	def dispatch String generateProgram(SimpleKeyboardInput ski, TelluriumGeneratorContext ctx)'''
	«if(ski.target!==null){'''//target:«ski.target.generateProgram(ctx).trim»'''}»
	//.sendKeys(«IF ski.target!==null»«ski.target.generateProgram(ctx).trim»,«ENDIF»"«ski.keySequence»");
	new Actions(driver).sendKeys(«IF ski.target!==null»«ski.target.generateProgram(ctx).trim»,«ENDIF»"«ski.keySequence»").build().perform();
	'''
	
	def dispatch String generateProgram(ComplexKeyboardInput cki, TelluriumGeneratorContext ctx){
		if(!ctx.importList.exists[im | im === "org.openqa.selenium.Keys"]){
			ctx.importList+="org.openqa.selenium.Keys"
		}
	'''
	«if(cki.target!==null){'''//target:«cki.target.generateProgram(ctx).trim»'''}»
	//.keyDown(Keys.«cki.modifier.interpretModifier»).sendKeys(«IF cki.target!==null»«cki.target.generateProgram(ctx).trim»,«ENDIF»"«cki.keySequence»").keyUp(Keys.«cki.modifier.interpretModifier»);
	new Actions(driver).keyDown(Keys.«cki.modifier.interpretModifier»).sendKeys(«IF cki.target!==null»«cki.target.generateProgram(ctx).trim»,«ENDIF»"«cki.keySequence»").keyUp(Keys.«cki.modifier.interpretModifier»).build().perform();
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
	«if(mi.target!==null){'''//target:«mi.target.generateProgram(ctx).trim»'''}»
	new Actions(driver).«mi.MAction.interpretMouseAction»(«IF mi.target!==null»«mi.target.generateProgram(ctx).trim»«ENDIF»).build().perform();
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
	
	def dispatch String generateProgram(OpenPage openPage, TelluriumGeneratorContext ctx)'''driver.get(«openPage.target.generateProgram(ctx)»);'''
	
	
	
	def dispatch String generateProgram(Navigate navi, TelluriumGeneratorContext ctx)'''driver.navigate().«navi.action»();'''
	
	def dispatch String generateProgram(Window window, TelluriumGeneratorContext ctx)'''driver.manage().window().«window.action»();'''
	
	def dispatch String generateProgram(Cookie cookie, TelluriumGeneratorContext ctx){
		cookie.action.generateProgram(ctx)
	}
	
	def dispatch String generateProgram(CookieAdd cookieAdd, TelluriumGeneratorContext ctx)'''
	driver.manage().addCookie(new Cookie("«cookieAdd.key»","«cookieAdd.value»"));
	'''
	
	def dispatch String generateProgram(CookieDelete cookieDelete, TelluriumGeneratorContext ctx)'''
	«IF(cookieDelete.key===null)»
	driver.manage().deleteAllCookies();
	«ELSE»
	driver.manage().deleteCookieNamed("«cookieDelete.key»");
	«ENDIF»
	'''
	
	def dispatch String generateProgram(VariableDeclaration vd, TelluriumGeneratorContext ctx)'''
	«IF vd.value instanceof ElementExpressions»
	«ElementSelectorGenerator.generateDeclaration(vd.value as ElementExpressions, vd.name, ctx)»;
	«ELSEIF vd.value instanceof ExtractElementFromList»
	«ElementSelectorGenerator.generateDeclaration(vd.value as ExtractElementFromList, vd.name, (vd.value as ExtractElementFromList).index.generateProgram(ctx), ctx)»;
	«ELSE»
	«vd.value.inferType(ctx)» «vd.name» = «vd.value.generateProgram(ctx)»;
	«ENDIF»
	'''
	
	def String inferType(Variables vars, TelluriumGeneratorContext ctx){
		if(vars instanceof DoubleLitera){
			return "double"
		}else if(vars instanceof IntLitera){
			return "int"
		}else if(vars instanceof StringLitera){
			return "String"
		}else if(vars instanceof VarExpression){
			return (vars as VarExpression).^var.value.inferType(ctx)
		}
		return "Object"
	}
		
	def dispatch String generateProgram(Variables vars, TelluriumGeneratorContext ctx)''''''
	
	def dispatch String generateProgram(DoubleLitera fl, TelluriumGeneratorContext ctx)'''«fl.^val»'''
	
	def dispatch String generateProgram(IntLitera il, TelluriumGeneratorContext ctx)'''«il.^val»'''
	
	def dispatch String generateProgram(StringLitera sl, TelluriumGeneratorContext ctx)'''"«sl.^val»"'''
	
	def dispatch String generateProgram(VarExpression sl, TelluriumGeneratorContext ctx)'''«sl.^var.name»'''
	
	def dispatch String generateProgram(ElementReferences exp, TelluriumGeneratorContext ctx)''''''
	
	def dispatch String generateProgram(LocateElement exp, TelluriumGeneratorContext ctx)'''
	«ElementSelectorGenerator.generateSelector(exp.element, ctx)»
	'''
	
	def dispatch String generateProgram(ElementReference exp, TelluriumGeneratorContext ctx)'''«exp.ref.name»'''
	
	def dispatch String generateProgram(ExtractEleFromListRef efr, TelluriumGeneratorContext ctx)'''
	«ElementSelectorGenerator.generateExtractor(efr.extractRef)».get(«efr.extractRef.index.generateProgram(ctx)»)
	'''
	
	def dispatch String generateProgram(AssertStatement assert, TelluriumGeneratorContext ctx){
		AssertionGenerator.generateAssertion(assert,ctx,this)
	}
	
}

