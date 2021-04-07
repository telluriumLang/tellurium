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

/**
 * TelluriumScopeProvider - The Scope system for Tellurium
 */
class TelluriumScopeProvider extends AbstractDeclarativeScopeProvider {
	
	def IScope scope_VarExpression_var(VarExpression varExp, EReference ref){
		var topStatement = varExp as EObject
		while(!(topStatement.eContainer instanceof TestCase)){
			topStatement = topStatement.eContainer
		}
		varExp.eContainer.extractScope(new AuxiliaryScopeContext(topStatement))
	}
	
	def IScope scope_ElementsSelectorRef_ref(ElementsSelectorRef esrf, EReference ref){
		esrf.eContainer.extractScope(new AuxiliaryScopeContext(esrf.eContainer))
	}
	
	def IScope scope_ElementReference_ref(ElementReference erf, EReference ref){
		erf.eContainer.extractScope(new AuxiliaryScopeContext(erf.eContainer))
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
