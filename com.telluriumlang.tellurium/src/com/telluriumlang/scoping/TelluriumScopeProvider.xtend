/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.scoping

import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.IScope
import com.telluriumlang.tellurium.TestCase
import com.telluriumlang.tellurium.VarExpression
import com.telluriumlang.tellurium.VariableDeclaration

import static org.eclipse.xtext.scoping.Scopes.*
import org.eclipse.emf.ecore.EObject
import java.util.ArrayList
import com.telluriumlang.tellurium.OpenPage

/**
 * TelluriumScopeProvider - The Scope system for Tellurium
 */
class TelluriumScopeProvider extends AbstractDeclarativeScopeProvider {
	
	def IScope scope_VarExpression_var(VarExpression varExp, EReference ref){
		varExp.eContainer.extractScope(new AuxiliaryScopeContext(varExp))
	}
	
	def dispatch IScope extractScope(VariableDeclaration varDec, AuxiliaryScopeContext ctx){
		varDec.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(OpenPage varDec, AuxiliaryScopeContext ctx){
		varDec.eContainer.extractScope(ctx)
	}
	
	def dispatch IScope extractScope(TestCase tc, AuxiliaryScopeContext ctx){
		var elements = new ArrayList<VariableDeclaration>()
		var varDecIter = tc.statements.filter(VariableDeclaration)
		for(statement: varDecIter){
			if(statement.value == ctx.refExp){
				return scopeFor(elements)
			}
			elements.add(statement)
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
