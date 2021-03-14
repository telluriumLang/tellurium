package com.telluriumlang.ui.generator

import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2

class IFileSystemAccess2Wrapper extends EclipseResourceFileSystemAccess2{
	
	override getProject() {
		return super.project;
	}
	
}
