/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.scoping

import java.util.ArrayList

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.IScope
import com.telluriumlang.tellurium.TestCase
import com.telluriumlang.tellurium.VarExpression
import com.telluriumlang.tellurium.VariableDeclaration
import com.telluriumlang.tellurium.OpenPage
import com.telluriumlang.tellurium.ElementsSelectorRef
import com.telluriumlang.tellurium.ElementReference

import static org.eclipse.xtext.scoping.Scopes.*
import com.telluriumlang.tellurium.KeyboardInput
import com.telluriumlang.tellurium.MouseInput
import com.telluriumlang.tellurium.SimpleKeyboardInput
import com.telluriumlang.tellurium.ComplexKeyboardInput
import com.telluriumlang.tellurium.ExtractElementFromList
import com.telluriumlang.tellurium.GetInfoStatement
import com.telluriumlang.tellurium.GetAttributeStatement
import com.telluriumlang.tellurium.AssertEquals
import com.telluriumlang.tellurium.AssertNotEquals
import com.telluriumlang.tellurium.AssertIn
import com.telluriumlang.tellurium.AssertNotIn
import com.telluriumlang.tellurium.AssertStatement

/**
 * TelluriumScopeProvider - The Scope system for Tellurium
 */
class TelluriumScopeProvider extends AbstractDeclarativeScopeProvider {
	
	def IScope scope_VarExpression_var(VarExpression varExp, EReference ref){
		
		varExp.eContainer.extractScope(new AuxiliaryScopeContext(varExp.findTopStatmentInTestcase))
	}
	
	def IScope scope_ElementsSelectorRef_ref(ElementsSelectorRef esrf, EReference ref){
		esrf.eContainer.extractScope(new AuxiliaryScopeContext(esrf.findTopStatmentInTestcase))
	}
	
	def IScope scope_ElementReference_ref(ElementReference erf, EReference ref){
		erf.eContainer.extractScope(new AuxiliaryScopeContext(erf.findTopStatmentInTestcase))
	}
	
	def EObject findTopStatmentInTestcase(EObject varExp){
		var topStatement = varExp
		while(!(topStatement.eContainer instanceof TestCase)){
			topStatement = topStatement.eContainer
		}
		return topStatement
	}
	
	def dispatch IScope extractScope(VariableDeclaration varDec, AuxiliaryScopeContext ctx){
		varDec.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(OpenPage varDec, AuxiliaryScopeContext ctx){
		varDec.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(KeyboardInput ki, AuxiliaryScopeContext ctx){
		ki.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(MouseInput mi, AuxiliaryScopeContext ctx){
		mi.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(SimpleKeyboardInput ski,AuxiliaryScopeContext ctx){
		ski.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(ComplexKeyboardInput cki, AuxiliaryScopeContext ctx){
		cki.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(ExtractElementFromList varDec, AuxiliaryScopeContext ctx){
		varDec.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(AssertEquals aeq, AuxiliaryScopeContext ctx){
		aeq.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(AssertNotEquals aneq, AuxiliaryScopeContext ctx){
		aneq.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(AssertIn asi, AuxiliaryScopeContext ctx){
		asi.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(AssertNotIn ani, AuxiliaryScopeContext ctx){
		ani.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(AssertStatement ass, AuxiliaryScopeContext ctx){
		ass.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(GetInfoStatement gis, AuxiliaryScopeContext ctx){
		gis.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(GetAttributeStatement gas, AuxiliaryScopeContext ctx){
		gas.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(TestCase tc, AuxiliaryScopeContext ctx){
		var elements = new ArrayList<VariableDeclaration>()
		for(statement: tc.statements){
			if(statement == ctx.refExp){
				return scopeFor(elements)
			}
			if(statement instanceof VariableDeclaration){
				var decStat = statement as VariableDeclaration
				elements.add(decStat)
			}
		}
		return scopeFor(elements)
	}
	
	private static class AuxiliaryScopeContext {
		EObject refExp;
		
		new(EObject refExp){
			this.refExp = refExp
		}
	}
}
