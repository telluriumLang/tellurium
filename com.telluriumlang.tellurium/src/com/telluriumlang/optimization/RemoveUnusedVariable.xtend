package com.telluriumlang.optimization

import com.telluriumlang.tellurium.AutomationTestSet
import com.telluriumlang.tellurium.TestCase
import com.telluriumlang.tellurium.VariableAssignment
import com.telluriumlang.tellurium.VariableDeclaration
import java.util.HashMap
import org.eclipse.emf.ecore.EObject

class RemoveUnusedVariable extends OptimizationOperation{
	
	var HashMap<String, Integer> symbolRefCnt = null;
	
	override doOptimize(AutomationTestSet ats) {
		var testcases = ats.testcases;
		for(TestCase tc: testcases){
			var performTask = true
			while(performTask){
				performTask = false
				this.symbolRefCnt = new HashMap<String, Integer>();
				tc.statements.forEach[collectInformation]
				for(var iter = tc.statements.iterator; iter.hasNext(); ){
					var ts = iter.next;
					 if(ts instanceof VariableDeclaration){
					 	if(!symbolRefCnt.containsKey(ts.name)){
					 		iter.remove()
					 		performTask = true
					 	}
					 }else if(ts instanceof VariableAssignment){
					 	if(!symbolRefCnt.containsKey(ts.ref.name)){
					 		iter.remove()
					 		performTask = true
					 	}
					 }
				}
			}
		}
		return ats
	}
	
	def private void collectInformation(EObject obj){
		var refs =  obj.eCrossReferences
		for(EObject refObj: refs){
			if(refObj instanceof VariableDeclaration){
				var varDec = refObj as VariableDeclaration
				if(symbolRefCnt.containsKey(varDec.name)){
					symbolRefCnt.put(varDec.name, symbolRefCnt.get(varDec.name) + 1);
				}else{
					symbolRefCnt.put(varDec.name, 1);
				}
			}
		}
		for(EObject child: obj.eContents){
			collectInformation(child)
		}
	}
	
}
