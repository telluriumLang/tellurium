/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
class TelluriumStandaloneSetup extends TelluriumStandaloneSetupGenerated {

	def static void doSetup() {
		new TelluriumStandaloneSetup().createInjectorAndDoEMFRegistration()
	}
}
