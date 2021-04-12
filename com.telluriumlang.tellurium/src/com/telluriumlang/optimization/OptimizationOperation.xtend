package com.telluriumlang.optimization

import com.telluriumlang.tellurium.AutomationTestSet

abstract class OptimizationOperation {
	
	def abstract AutomationTestSet doOptimize(AutomationTestSet ats)
	
}
