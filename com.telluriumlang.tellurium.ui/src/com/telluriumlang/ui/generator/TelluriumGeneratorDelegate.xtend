package com.telluriumlang.ui.generator

import org.eclipse.core.resources.IProject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.GeneratorDelegate
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.core.IClasspathEntry
import org.eclipse.jdt.launching.JavaRuntime
import org.eclipse.jdt.junit.JUnitCore
import java.util.HashSet

class TelluriumGeneratorDelegate extends GeneratorDelegate {
	
		
	override void generate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.generate(input, fsa, context)
		
		if (fsa instanceof IFileSystemAccess2Wrapper) {
			val project = (fsa as IFileSystemAccess2Wrapper).project;
			project.init();
		}
		
	}
	
	
	private def init(IProject project) {
		
		val generatedFolder = project.getFolder("src-gen");
		
		var projectDescription = project.description
		if (!projectDescription.natureIds.contains(JavaCore.NATURE_ID)) {
			projectDescription.natureIds = projectDescription.natureIds + #[JavaCore.NATURE_ID];
			project.setDescription(projectDescription, null);
		}
		
		var javaProject = JavaCore.create(project);
		var existingClasspath = javaProject.rawClasspath;
		
		val classPathEntries = new HashSet<IClasspathEntry>()
		classPathEntries.addAll(existingClasspath);
		
		
		
		// JRE Support
		if (!existingClasspath.exists[(entryKind === IClasspathEntry.CPE_CONTAINER)]) {		
			classPathEntries.add(JavaRuntime.getDefaultJREContainerEntry);
		}
		
		// Set src-gen to source folder
		if (!existingClasspath.exists[(entryKind === IClasspathEntry.CPE_SOURCE) && (path == generatedFolder.fullPath)]) {
			classPathEntries.add(JavaCore.newSourceEntry(generatedFolder.fullPath));
		}
		
		// Support JUnit 4
		if (!existingClasspath.exists[(entryKind === IClasspathEntry.CPE_CONTAINER) && (path == JUnitCore.JUNIT4_CONTAINER_PATH)]) {
			classPathEntries.add(JavaCore.newContainerEntry(JUnitCore.JUNIT4_CONTAINER_PATH));
		}
		
		System.out.println(classPathEntries);
				
		javaProject.setRawClasspath(classPathEntries, null);
		
	}
	
}
