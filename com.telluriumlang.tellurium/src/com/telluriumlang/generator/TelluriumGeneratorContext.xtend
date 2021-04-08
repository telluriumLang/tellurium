/*
 * Tellurium - A DSL for automation testing
 */
 
 package com.telluriumlang.generator

import java.util.List
import java.util.ArrayList

class TelluriumGeneratorContext {
	
	new(){
		importList = new ArrayList<String>();
		importList.addAll( #[
			'org.junit.Assert',
			'org.junit.Before',
			'org.junit.Test',
			'org.openqa.selenium.WebDriver',
			'org.openqa.selenium.interactions.*',
			'org.openqa.selenium.*'
		]);
	}
	
	var List<String> importList;
	var String className;
	var String packageName;
	
	def void setClassName(String className){
		var goodClassName = className;
		if(goodClassName !== null){
			goodClassName = className.replaceAll("\\.","")
		}
		this.className = goodClassName;
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
	
	def List<String> getImportList(){
		return this.importList;
	}
	
}