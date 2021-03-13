/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.ide

import com.google.inject.Guice
import com.telluriumlang.TelluriumRuntimeModule
import com.telluriumlang.TelluriumStandaloneSetup
import org.eclipse.xtext.util.Modules2

/**
 * Initialization support for running Xtext languages as language servers.
 */
class TelluriumIdeSetup extends TelluriumStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new TelluriumRuntimeModule, new TelluriumIdeModule))
	}
	
}
