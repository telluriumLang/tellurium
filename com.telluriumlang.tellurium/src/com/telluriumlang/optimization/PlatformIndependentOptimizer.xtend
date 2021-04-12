package com.telluriumlang.optimization

import com.telluriumlang.tellurium.AutomationTestSet

class PlatformIndependentOptimizer {
	
	var AutomationTestSet ats;
	val operationsPipeLine = #[
		new ConstantPropagation(),
		new RemoveUnusedVariable()
	];
	
	private new(AutomationTestSet ats){
		this.ats = ats
	}
	
	def static AutomationTestSet doOptimize(AutomationTestSet ats) {
		return (new PlatformIndependentOptimizer(ats)).performPipeline();
	}
	
	def AutomationTestSet performPipeline(){
		for(OptimizationOperation operation : operationsPipeLine){
			this.ats = operation.doOptimize(this.ats)
		}
		return this.ats
	}
}
