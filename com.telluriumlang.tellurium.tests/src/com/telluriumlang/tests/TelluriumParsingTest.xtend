/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.tests

import com.google.inject.Inject
import com.telluriumlang.tellurium.AutomationTestSet
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(TelluriumInjectorProvider)
class TelluriumParsingTest {
	@Inject
	ParseHelper<AutomationTestSet> parseHelper
	
	@Test
	def void loadModel() {
		val result = parseHelper.parse('''
			Hello Xtext!
		''')
		Assert.assertNotNull(result)
		val errors = result.eResource.errors
		Assert.assertTrue('''Unexpected errors: «errors.join(", ")»''', errors.isEmpty)
	}
}
