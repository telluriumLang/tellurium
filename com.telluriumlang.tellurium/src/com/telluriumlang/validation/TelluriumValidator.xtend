/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.validation

import org.eclipse.xtext.validation.Check
import com.telluriumlang.tellurium.AutomationTestSet
import com.telluriumlang.tellurium.DriverConfig
import com.telluriumlang.tellurium.TelluriumPackage
import com.telluriumlang.semantics.validation.TelluriumSemanticsValidator
import com.telluriumlang.tellurium.GetInfoStatement
import com.telluriumlang.tellurium.GetInfoStatementAction
import com.telluriumlang.tellurium.MouseMove

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
	
	@Check
	def checkGetInfoStatementAction(GetInfoStatement gis){
		var window = gis.window
		var target = gis.target
		if(window !== null && target !== null ){
			error("Cannot define both element and window at the same time", 
					TelluriumPackage.Literals.GET_INFO_STATEMENT__ACTION,
					TelluriumErrorTypes.DUPLICATED_GET_INFO_TARGET)
		}else if (window === null && target === null){
			error("A target should be defined", 
					TelluriumPackage.Literals.GET_INFO_STATEMENT__ACTION,
					TelluriumErrorTypes.NO_GET_INFO_TARGET)
		}else{
			if(gis.action == GetInfoStatementAction.TITLE ){
				if( target !== null ){
					error("Get title from element is not supported.", 
					TelluriumPackage.Literals.GET_INFO_STATEMENT__ACTION,
					TelluriumErrorTypes.GET_INFO_TARGET_INVALID)
				}
			}else{
				if( window !== null ){
					error("Get " + gis.action.getName + " from the window is not supported.", 
					TelluriumPackage.Literals.GET_INFO_STATEMENT__WINDOW,
					TelluriumErrorTypes.GET_INFO_WINDOW_INVALID)
				}
			}
		}
	}
	
	@Check
	def checkMouseMove(MouseMove mm){
		if(mm.target===null&&(mm.XOffset===null||mm.YOffset===null)){
			error("Mouse move instruction (to element / by offset) should be specified",
				TelluriumPackage.Literals.MOUSE_MOVE__XOFFSET,
				TelluriumErrorTypes.MOUSE_MOVE_WITHOUT_INSTRUCTION)
		}
	}
	
}
