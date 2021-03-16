/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.validation

import org.eclipse.xtext.validation.Check
import com.telluriumlang.tellurium.AutomationTestSet
import com.telluriumlang.tellurium.DriverConfig
import com.telluriumlang.tellurium.TelluriumPackage
import com.telluriumlang.semantics.validation.TelluriumSemanticsValidator

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class TelluriumValidator extends TelluriumSemanticsValidator {
	
	@Check
	def checkDriverConfig(AutomationTestSet ats){
		var num = ats.testConfig.filter[t | t instanceof DriverConfig].size;
		if(num > 1){
			error("Cannot define more than 1 driver", 
					TelluriumPackage.Literals.AUTOMATION_TEST_SET__TEST_CONFIG,
					TelluriumErrorTypes.DUPLICATED_DRIVER_CFG)
		}
	}
	
}
