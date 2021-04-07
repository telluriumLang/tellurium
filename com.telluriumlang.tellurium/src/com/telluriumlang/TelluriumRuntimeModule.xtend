/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang

import org.eclipse.xsemantics.runtime.StringRepresentation
import com.telluriumlang.semantics.TelluriumSemanticsStringRep

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class TelluriumRuntimeModule extends AbstractTelluriumRuntimeModule {
	
	def Class<? extends StringRepresentation> bindStringRepresentation() {
	    return TelluriumSemanticsStringRep;
	}

}
