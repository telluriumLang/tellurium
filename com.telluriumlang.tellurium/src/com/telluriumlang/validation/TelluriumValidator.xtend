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
import com.telluriumlang.tellurium.TestCase
import com.telluriumlang.tellurium.TestStatement
import com.telluriumlang.tellurium.QuitAndClose
import com.telluriumlang.tellurium.QuitAndCloseAction
import org.eclipse.emf.common.util.EList
import com.telluriumlang.tellurium.VariableDeclaration
import org.eclipse.emf.ecore.EObject

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
		if(mm.target===null&&mm.offset===null){
			error("Mouse move instruction (to element / by offset) should be specified",
				TelluriumPackage.Literals.MOUSE_MOVE__OFFSET,
				TelluriumErrorTypes.MOUSE_MOVE_WITHOUT_INSTRUCTION)
		}
	}
	
	@Check
	def checkStatementAfterQuit(TestCase tc){
		if(tc.statements.fold(1,[state,stmt|stmt.computeQuitState(state)])==0){
			error("No statement allowed after quit",
				TelluriumPackage.Literals.TEST_CASE__STATEMENTS,
				TelluriumErrorTypes.STATEMENT_AFTER_QUIT)
		}
	}
	
	@Check
	def checkTestCaseName(TestCase tc){
		if(ValidatorConstant.JAVA_RESERVE_KEYWORDS.contains(tc.name)){
			error("The name of Test: \""+tc.name+"\" is a reserved keyword of Java",
				TelluriumPackage.Literals.TEST_CASE__NAME,
				TelluriumErrorTypes.CONFLICT_WITH_JAVA_KEYWORD)
		}
		var program = tc.eContainer as AutomationTestSet
		var nameCnt = program.testcases.filter(TestCase).filter[t | t.name !== null && t.name == tc.name].size
		if(nameCnt > 1){
			error("The name of Test: \""+tc.name+"\" is not unique in this test set",
				TelluriumPackage.Literals.TEST_CASE__NAME,
				TelluriumErrorTypes.DUPLICATED_NAME)
		}
	}
	
	@Check
	def checkVariableDeclarationName(VariableDeclaration varDec){
		if(ValidatorConstant.JAVA_RESERVE_KEYWORDS.contains(varDec.name)){
			error("The name of variable \""+varDec.name+"\" is a reserved keyword of Java",
				TelluriumPackage.Literals.VARIABLE_DECLARATION__NAME,
				TelluriumErrorTypes.CONFLICT_WITH_JAVA_KEYWORD)
		}
		var testCase = varDec.eContainer as TestCase
		var nameCnt = testCase.statements.filter(VariableDeclaration).filter[v | v.name !== null && v.name == varDec.name].size
		if(nameCnt > 1){
			error("The name of variable \""+ varDec.name+"\" is not unique in this test case",
				TelluriumPackage.Literals.VARIABLE_DECLARATION__NAME,
				TelluriumErrorTypes.DUPLICATED_NAME)
		}
	}
	
	@Check
	def unusedVarCheck(VariableDeclaration varDec){
		if(!findReference(varDec.eContainer,varDec)){
			warning("Variable "+ varDec.name+" is never used",
				TelluriumPackage.Literals.VARIABLE_DECLARATION__NAME,
				TelluriumErrorTypes.DUPLICATED_NAME)
		}
	}
	
	/*quitState
	 * 0=encountered other statement after encounter
	 * 1=no quit statement encountered
	 * 2=encountered quit statement
	 */
	
	dispatch def int computeQuitState(TestStatement stmt, int quitState){
		if(quitState == 2){
			return 0
		}else{
			return quitState
		}
	}
	
	dispatch def int computeQuitState(QuitAndClose qacStmt, int quitState){
		if(qacStmt.action == QuitAndCloseAction.QUIT){
			return 2
		}else{
			if(quitState == 2){
				return 0
			}else{
				return quitState
		}
		}
	}
	
	@Check
	def checkDuplicatedQuit(TestCase tc){
		val quitCount=tc.statements.countQuitForStatementList(0);
		if(quitCount>1){
			error("Quit can be invoked at most once within a test case",
				TelluriumPackage.Literals.TEST_CASE__STATEMENTS,
				TelluriumErrorTypes.DUPLICATED_QUIT)
		}
	}
	
	def countQuitForStatementList(EList<TestStatement> stmts, int startCount){
		stmts.fold(startCount, [previousCount,stmt|stmt.countQuit(previousCount)])
	}
	
	dispatch def int countQuit(TestStatement stmt, int quitCount){
		return quitCount
	}
	
	dispatch def int countQuit(QuitAndClose qacStmt, int quitCount){
		if(qacStmt.action == QuitAndCloseAction.QUIT){
			return quitCount + 1
		}else{
			return quitCount
		}
	}
	
	/**
	 * Traverse the AST to find the reference
	 * @return true is reference exists
	 */
	def boolean findReference(EObject astRoot, EObject ref){
		var refs =  astRoot.eCrossReferences
		for(EObject refObj: refs){
			if(ref == refObj){
				return true;
			}
		}
		for(EObject child: astRoot.eContents){
			if(findReference(child, ref)){
				return true
			}
		}
		return false;
	}
	
}
