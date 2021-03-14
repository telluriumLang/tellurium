/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.ui

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.generator.GeneratorDelegate
import com.telluriumlang.ui.generator.TelluriumGeneratorDelegate
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2
import com.telluriumlang.ui.generator.IFileSystemAccess2Wrapper

/**
 * Use this class to register components to be used within the Eclipse IDE.
 */
@FinalFieldsConstructor
class TelluriumUiModule extends AbstractTelluriumUiModule {
	
	def Class<? extends GeneratorDelegate> bindGeneratorDelegate() {
		TelluriumGeneratorDelegate
	}
	
	def Class<? extends EclipseResourceFileSystemAccess2> bindEclipseResourceFileSystemAccess2() {
		IFileSystemAccess2Wrapper
	}
	
}
