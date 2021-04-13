/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.ui.quickfix

import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import com.telluriumlang.validation.TelluriumErrorTypes
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor

class TelluriumQuickfixProvider extends DefaultQuickfixProvider {

	@Fix(TelluriumErrorTypes.GET_INFO_TARGET_INVALID)
	def capitalizeName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Change to window', 'Change the reference to window', null) [
			context |
			val xtextDocument = context.xtextDocument
			xtextDocument.replace(issue.offset,issue.length, 'window')
		]
	}
}
