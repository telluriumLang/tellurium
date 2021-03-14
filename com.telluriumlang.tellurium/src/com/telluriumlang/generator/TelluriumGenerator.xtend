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

/**
 * Generates code from the Tellurium model on save.
 */
class TelluriumGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		var ctx = loadCtx(resource);
		var filePath = ctx.packageName.replaceAll("\\.","/") 
		filePath = filePath + "/" + ctx.className + ".java"
		val model = resource.contents.head as AutomationTestSet;
		fsa.generateFile(filePath, model.generateProgram(ctx));
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
	«IF !ctx.packageName.empty »package «ctx.packageName»;«ENDIF»
	
	import org.junit.Assert;
	import org.junit.Before;
	import org.junit.Test;
	
	public class «ctx.className» {
		
		@Before
		public void setup() {
			System.out.println("Pepare");
		}
		
		«ats.testcases.map[generateProgram(ctx)].join('\n')»
	
	}
	'''
	
	def dispatch String generateProgram(TestCase ats, TelluriumGeneratorContext ctx)'''
	@Test
	public void «ats.name»() {
		//TODO: Test will be added here
	}
	'''
}

