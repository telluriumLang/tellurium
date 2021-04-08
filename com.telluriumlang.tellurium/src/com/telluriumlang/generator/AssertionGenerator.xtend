package com.telluriumlang.generator

import com.telluriumlang.tellurium.AssertStatement
import com.telluriumlang.tellurium.AssertTrue
import com.telluriumlang.tellurium.AssertFalse
import com.telluriumlang.tellurium.AssertNull
import com.telluriumlang.tellurium.AssertNotNull
import com.telluriumlang.tellurium.AssertEquals
import com.telluriumlang.tellurium.AssertNotEquals
import com.telluriumlang.tellurium.AssertIn
import com.telluriumlang.tellurium.AssertNotIn

class AssertionGenerator {
	def static String generateAssertion(AssertStatement assert, TelluriumGeneratorContext ctx, TelluriumGenerator gen){
		var message = ""
		if(assert.message!==null){
			message="\""+assert.message+"\","
		}
		assert.doGenerate(message,ctx,gen)
		
	}
	def static dispatch String doGenerate(AssertTrue at, String message, TelluriumGeneratorContext ctx, TelluriumGenerator gen)'''
	Assert.assertTrue(«message»«gen.generateProgram(at.actual,ctx)»);
	'''
	
	def static dispatch String doGenerate(AssertFalse af, String message, TelluriumGeneratorContext ctx, TelluriumGenerator gen)'''
	Assert.assertFalse(«message»«gen.generateProgram(af.actual,ctx)»);
	'''
	
	def static dispatch String doGenerate(AssertNull an, String message, TelluriumGeneratorContext ctx, TelluriumGenerator gen)'''
	Assert.assertNull(«message»«gen.generateProgram(an.actual,ctx)»);
	'''
	
	def static dispatch String doGenerate(AssertNotNull an, String message, TelluriumGeneratorContext ctx, TelluriumGenerator gen)'''
	Assert.assertNotNull(«message»«gen.generateProgram(an.actual,ctx)»);
	'''
	
	def static dispatch String doGenerate(AssertEquals ae, String message, TelluriumGeneratorContext ctx, TelluriumGenerator gen)'''
	Assert.assertEquals(«message»«gen.generateProgram(ae.actual,ctx)»,«gen.generateProgram(ae.actual,ctx)»);
	'''
	
	def static dispatch String doGenerate(AssertNotEquals ane, String message, TelluriumGeneratorContext ctx, TelluriumGenerator gen)'''
	Assert.assertNotEquals(«message»«gen.generateProgram(ane.actual,ctx)»,«gen.generateProgram(ane.actual,ctx)»);
	'''
	
	def static dispatch String doGenerate(AssertIn ai, String message, TelluriumGeneratorContext ctx, TelluriumGenerator gen)'''
	Assert.assertTrue(«message»«gen.generateProgram(ai.hayStack,ctx)».contains(«gen.generateProgram(ai.needle,ctx)»));
	'''
	
	def static dispatch String doGenerate(AssertNotIn ani, String message, TelluriumGeneratorContext ctx, TelluriumGenerator gen)'''
	Assert.assertFalse(«message»«gen.generateProgram(ani.hayStack,ctx)».contains(«gen.generateProgram(ani.needle,ctx)»));
	'''
}