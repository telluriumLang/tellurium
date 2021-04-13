package com.telluriumlang.optimization

import com.telluriumlang.tellurium.AssertEquals
import com.telluriumlang.tellurium.AssertFalse
import com.telluriumlang.tellurium.AssertIn
import com.telluriumlang.tellurium.AssertNotEquals
import com.telluriumlang.tellurium.AssertNotIn
import com.telluriumlang.tellurium.AssertNotNull
import com.telluriumlang.tellurium.AssertNull
import com.telluriumlang.tellurium.AssertTrue
import com.telluriumlang.tellurium.AutomationTestSet
import com.telluriumlang.tellurium.DoubleLitera
import com.telluriumlang.tellurium.ElementReference
import com.telluriumlang.tellurium.ElementReferences
import com.telluriumlang.tellurium.ExtractElementFromList
import com.telluriumlang.tellurium.FindElement
import com.telluriumlang.tellurium.IntLitera
import com.telluriumlang.tellurium.KeyboardInput
import com.telluriumlang.tellurium.MouseDragNDrop
import com.telluriumlang.tellurium.MouseMove
import com.telluriumlang.tellurium.OpenPage
import com.telluriumlang.tellurium.SimpleMouseInput
import com.telluriumlang.tellurium.StringLitera
import com.telluriumlang.tellurium.TelluriumFactory
import com.telluriumlang.tellurium.TestCase
import com.telluriumlang.tellurium.VarExpression
import com.telluriumlang.tellurium.VariableAssignment
import com.telluriumlang.tellurium.VariableDeclaration
import com.telluriumlang.tellurium.Variables
import java.util.HashMap
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import java.util.ArrayList

class ConstantPropagation extends OptimizationOperation {

	var HashMap<String, VarContext> statusTable = null;
	
	private static class VarContext {
		Status status;
		int refCnt = 0;
		List<VariableAssignment> alreadyMerged = new ArrayList<VariableAssignment>();
		override toString()'''(s:«status», cnt: «refCnt»)'''
	}

	private enum Status {
		DEF,
		USED,
		BE_KILLED
	}

	override doOptimize(AutomationTestSet ats) {
		var testcases = ats.testcases;
		for (TestCase tc : testcases) {
			statusTable = new HashMap<String, VarContext>();
			tc.statements.forEach[collectInfo]
			System.out.println(statusTable)
			for (var iter = tc.statements.iterator; iter.hasNext;) {
				var ts = iter.next
				if (ts instanceof VariableAssignment) {
					var ctx = statusTable.get(ts.ref.name)
					if(ctx.alreadyMerged.contains(ts) || ctx.status !== Status.BE_KILLED){
						iter.remove
					}
				}
			}
			tc.statements.filter[t|!(t instanceof VariableDeclaration || t instanceof VariableAssignment)].forEach[updateAST]
		}
		return ats
	}
	
	def dispatch void collectInfo(VariableAssignment varAss){
		varAss.value.collectInfo
		if(statusTable.get(varAss.ref.name).status != Status.DEF ){
			statusTable.get(varAss.ref.name).status = Status.BE_KILLED
		}else {
			varAss.ref.value = EcoreUtil.copy(varAss.value)
			statusTable.get(varAss.ref.name).alreadyMerged.add(varAss)
		}
	}
	
	def dispatch void collectInfo(EObject obj){
		var refs = obj.eCrossReferences
		for(r : refs){
			if(r instanceof VariableDeclaration){
				var ctx = statusTable.get(r.name)
				if(ctx.status != Status.BE_KILLED){
					ctx.status = Status.USED
				}
				ctx.refCnt += 1
			}
		}
		for(content : obj.eContents){
			content.collectInfo
		}
	}
	
	def dispatch void collectInfo(VariableDeclaration varDec){
		var varCtx = new VarContext();
		varCtx.status = Status.DEF;
		statusTable.put(varDec.name, varCtx)
		varDec.value.collectInfo
	}
	
	def dispatch void updateAST(VariableAssignment varAss){
		var value = varAss.value
		if(value instanceof DoubleLitera || value instanceof IntLitera || value instanceof StringLitera){
			var ctx = statusTable.get(varAss.ref.name)
			if(ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1) ){
				varAss.ref.value = EcoreUtil.copy(value)
			}
		}else if(value instanceof VarExpression){
			var exp = value as VarExpression
			if(statusTable.get(varAss.ref.name).status == Status.DEF 
				&& statusTable.get(exp.^var.name).status == Status.DEF 
			){
				varAss.ref.value = EcoreUtil.copy(exp.^var.value)
			}
		}
	}

	def dispatch void updateAST(OpenPage op) {
		if (op.target !== null && op.target instanceof VarExpression) {
			var opTarget = op.target as VarExpression
			var ctx = statusTable.get(opTarget.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
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
			var ctx = statusTable.get(kiTarget.ref.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ki.target = kiTarget.updateElementReference
			}
		}
	}

	def dispatch void updateAST(SimpleMouseInput mi) {
		if (mi.target !== null && mi.target instanceof ElementReference) {
			var miTarget = mi.target as ElementReference
			var ctx = statusTable.get(miTarget.ref.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				mi.target = miTarget.updateElementReference
			}
		}
	}

	def dispatch void updateAST(MouseMove mm) {
		if (mm.target !== null && mm.target instanceof ElementReference) {
			var mmTarget = mm.target as ElementReference
			var ctx = statusTable.get(mmTarget.ref.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				mm.target = mmTarget.updateElementReference
			}
		}
	}

	def dispatch void updateAST(MouseDragNDrop mdnd) {
		if (mdnd.source !== null && mdnd.source instanceof ElementReference) {
			var mdndSource = mdnd.source as ElementReference
			var ctx = statusTable.get(mdndSource.ref.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				mdnd.target = mdndSource.updateElementReference
			}
		}
		if (mdnd.target !== null && mdnd.target instanceof ElementReference) {
			var mdndTarget = mdnd.target as ElementReference
			var ctx = statusTable.get(mdndTarget.ref.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				mdnd.target = mdndTarget.updateElementReference
			}
		}
	}
	
	def dispatch void updateAST(AssertTrue ass) {
		if (ass.actual !== null && ass.actual instanceof VarExpression) {
			var assActual = ass.actual as VarExpression
			var ctx = statusTable.get(assActual.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.actual = assActual.^var.updateVariables
			}
		}
	}
	
	def dispatch void updateAST(AssertFalse ass) {
		if (ass.actual !== null && ass.actual instanceof VarExpression) {
			var assActual = ass.actual as VarExpression
			var ctx = statusTable.get(assActual.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.actual = assActual.^var.updateVariables
			}
		}
	}
	
	def dispatch void updateAST(AssertNull ass) {
		if (ass.actual !== null && ass.actual instanceof VarExpression) {
			var assActual = ass.actual as VarExpression
			var ctx = statusTable.get(assActual.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.actual = assActual.^var.updateVariables
			}
		}
	}
	
	def dispatch void updateAST(AssertNotNull ass) {
		if (ass.actual !== null && ass.actual instanceof VarExpression) {
			var assActual = ass.actual as VarExpression
			var ctx = statusTable.get(assActual.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.actual = assActual.^var.updateVariables
			}
		}
	}
	
	def dispatch void updateAST(AssertEquals ass) {
		if (ass.actual !== null && ass.actual instanceof VarExpression) {
			var assActual = ass.actual as VarExpression
			var ctx = statusTable.get(assActual.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.actual = assActual.^var.updateVariables
			}
		}
		if (ass.expected !== null && ass.expected instanceof VarExpression) {
			var assExpected = ass.actual as VarExpression
			var ctx = statusTable.get(assExpected.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.actual = assExpected.^var.updateVariables
			}
		}
	}
	
	def dispatch void updateAST(AssertNotEquals ass) {
		if (ass.actual !== null && ass.actual instanceof VarExpression) {
			var assActual = ass.actual as VarExpression
			var ctx = statusTable.get(assActual.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.actual = assActual.^var.updateVariables
			}
		}
		if (ass.unexpected !== null && ass.unexpected instanceof VarExpression) {
			var assUnexpected = ass.actual as VarExpression
			var ctx = statusTable.get(assUnexpected.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.actual = assUnexpected.^var.updateVariables
			}
		}
	}
	
	def dispatch void updateAST(AssertIn ass) {
		if (ass.needle !== null && ass.needle instanceof VarExpression) {
			var assNeedle = ass.needle as VarExpression
			var ctx = statusTable.get(assNeedle.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.needle = assNeedle.^var.updateVariables
			}
		}
		if (ass.hayStack !== null && ass.hayStack instanceof VarExpression) {
			var assHayStack = ass.needle as VarExpression
			var ctx = statusTable.get(assHayStack.^var)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.needle = assHayStack.^var.updateVariables
			}
		}
	}
	
	def dispatch void updateAST(AssertNotIn ass) {
		if (ass.needle !== null && ass.needle instanceof VarExpression) {
			var assNeedle = ass.needle as VarExpression
			var ctx = statusTable.get(assNeedle.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.needle = assNeedle.^var.updateVariables
			}
		}
		if (ass.hayStack !== null && ass.hayStack instanceof VarExpression) {
			var assHayStack = ass.needle as VarExpression
			var ctx = statusTable.get(assHayStack.^var.name)
			if (ctx.status == Status.DEF || (ctx.status == Status.USED && ctx.refCnt == 1)) {
				ass.needle = assHayStack.^var.updateVariables
			}
		}
	}
	
	def Variables updateVariables(VariableDeclaration varDec){
		return EcoreUtil.copy(varDec.value)
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
