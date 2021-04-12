package com.telluriumlang.optimization

import com.telluriumlang.tellurium.AutomationTestSet
import com.telluriumlang.tellurium.ElementReference
import com.telluriumlang.tellurium.ElementReferences
import com.telluriumlang.tellurium.ExtractElementFromList
import com.telluriumlang.tellurium.FindElement
import com.telluriumlang.tellurium.KeyboardInput
import com.telluriumlang.tellurium.MouseDragNDrop
import com.telluriumlang.tellurium.MouseMove
import com.telluriumlang.tellurium.OpenPage
import com.telluriumlang.tellurium.SimpleMouseInput
import com.telluriumlang.tellurium.StringLitera
import com.telluriumlang.tellurium.TelluriumFactory
import com.telluriumlang.tellurium.TestCase
import com.telluriumlang.tellurium.TestStatement
import com.telluriumlang.tellurium.VarExpression
import com.telluriumlang.tellurium.VariableAssignment
import com.telluriumlang.tellurium.VariableDeclaration
import java.util.HashMap
import org.eclipse.emf.ecore.util.EcoreUtil

class ConstantPropagation extends OptimizationOperation {

	var HashMap<VariableDeclaration, Status> statusTable = null;

	private enum Status {
		ORIGINAL_DEF,
		BE_KILLED
	}

	override doOptimize(AutomationTestSet ats) {
		var testcases = ats.testcases;
		for (TestCase tc : testcases) {
			statusTable = new HashMap<VariableDeclaration, Status>();
			for (TestStatement ts : tc.statements) {
				if (ts instanceof VariableDeclaration) {
					statusTable.put(ts, Status.ORIGINAL_DEF)
				} else if (ts instanceof VariableAssignment) {
					statusTable.put(ts.ref, Status.BE_KILLED)
				}
			}
			tc.statements.filter[t|!(t instanceof VariableDeclaration) && !( t instanceof VariableAssignment)].forEach [
				updateAST
			]
		}
		return ats
	}

	def dispatch void updateAST(OpenPage op) {
		if (op.target !== null && op.target instanceof VarExpression) {
			var opTarget = op.target as VarExpression
			if (statusTable.get(opTarget.^var) !== Status.BE_KILLED) {
				var strLitera = TelluriumFactory.eINSTANCE.createStringLitera
				if(opTarget.^var.value instanceof StringLitera){
					var oldStrLitera = opTarget.^var.value as StringLitera
					strLitera.^val = new String(oldStrLitera.^val)
					op.target = strLitera
				}
			}
		}
	}

	def dispatch void updateAST(KeyboardInput ki) {
		if (ki.target !== null && ki.target instanceof ElementReference) {
			var kiTarget = ki.target as ElementReference
			if (statusTable.get(kiTarget.ref) !== Status.BE_KILLED) {
				ki.target = updateElementReference(kiTarget)
			}
		}
	}

	def dispatch void updateAST(SimpleMouseInput mi) {
		if (mi.target !== null && mi.target instanceof ElementReference) {
			var miTarget = mi.target as ElementReference
			if (statusTable.get(miTarget.ref) !== Status.BE_KILLED) {
				mi.target = updateElementReference(miTarget)
			}
		}
	}

	def dispatch void updateAST(MouseMove mm) {
		if (mm.target !== null && mm.target instanceof ElementReference) {
			var mmTarget = mm.target as ElementReference
			if (statusTable.get(mmTarget.ref) !== Status.BE_KILLED) {
				mm.target = updateElementReference(mmTarget)
			}
		}
	}

	def dispatch void updateAST(MouseDragNDrop mdnd) {
		if (mdnd.source !== null && mdnd.source instanceof ElementReference) {
			var mdndSource = mdnd.source as ElementReference
			if (statusTable.get(mdndSource.ref) !== Status.BE_KILLED) {
				mdnd.target = updateElementReference(mdndSource)
			}
		}
		if (mdnd.target !== null && mdnd.target instanceof ElementReference) {
			var mdndTarget = mdnd.target as ElementReference
			if (statusTable.get(mdndTarget.ref) !== Status.BE_KILLED) {
				mdnd.target = updateElementReference(mdndTarget)
			}
		}
	}
	
	def ElementReferences updateElementReference(ElementReference targetRef) {
		if (targetRef.ref.value instanceof FindElement) {
			var locateEle = TelluriumFactory.eINSTANCE.createLocateElement
			var findElement =  targetRef.ref.value as FindElement
			locateEle.element = EcoreUtil.copy(findElement)
			targetRef.ref.value = findElement
			return locateEle
		} else if (targetRef.ref.value instanceof ExtractElementFromList) {
			var extractElementFromList = TelluriumFactory.eINSTANCE.createExtractEleFromListRef
			var extractEle = targetRef.ref.value as ExtractElementFromList
			extractElementFromList.extractRef = EcoreUtil.copy(extractEle)
			return extractElementFromList
		}
		return targetRef
	}

}
