/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.web

import com.google.inject.Guice
import com.google.inject.Injector
import com.telluriumlang.TelluriumRuntimeModule
import com.telluriumlang.TelluriumStandaloneSetup
import com.telluriumlang.ide.TelluriumIdeModule
import org.eclipse.xtext.util.Modules2

/**
 * Initialization support for running Xtext languages in web applications.
 */
class TelluriumWebSetup extends TelluriumStandaloneSetup {
	
	override Injector createInjector() {
		return Guice.createInjector(Modules2.mixin(new TelluriumRuntimeModule, new TelluriumIdeModule, new TelluriumWebModule))
	}
	
}
