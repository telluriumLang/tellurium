/*
 * Tellurium - A DSL for automation testing
 */
 
 package com.telluriumlang.generator
 
class TelluriumGeneratorContext {
	
	String className;
	String packageName;
	
	def void setClassName(String className){
		this.className = className;
	}
	
	def String getClassName(){
		return this.className;
	}
	
	def void setPackageName(String packageName){
		this.packageName = packageName;
	}
	
	def String getPackageName(){
		return this.packageName;
	}
	
}