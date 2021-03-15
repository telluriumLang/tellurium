package com.telluriumlang.ui.generator

import java.util.HashSet
import org.eclipse.core.resources.IProject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jdt.core.IClasspathEntry
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.junit.JUnitCore
import org.eclipse.jdt.launching.JavaRuntime
import org.eclipse.xtext.generator.GeneratorDelegate
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import java.util.concurrent.locks.ReentrantLock
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.SubMonitor

class TelluriumGeneratorDelegate extends GeneratorDelegate {
	
	val lock = new ReentrantLock();
	
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
		
		var setupJob = new Job("Preparing Telllurium environment") {
			
			override protected run(IProgressMonitor progressMonitor) {
				try{
					var subMonitor = SubMonitor.convert(progressMonitor,
						"Setting up Tellurium environment", SeleniumDependenciesProvider.LIB_URL_LIST.size +2
					);
					lock.lock();
					var javaProject = JavaCore.create(project);
				
					val existingClasspath = javaProject.rawClasspath;
				
					val classPathEntries = new HashSet<IClasspathEntry>()
					classPathEntries.addAll(existingClasspath);
					
					var setupMonitor = subMonitor.split(1);
					
					setupMonitor.taskName = "Checking environment configuration";
					
					// JRE Support
					if (!existingClasspath.exists[(entryKind === IClasspathEntry.CPE_CONTAINER)]) {		
						classPathEntries.add(JavaRuntime.getDefaultJREContainerEntry);
					}
					
					// Set src-gen to source folder
					if (!existingClasspath.exists[(entryKind === IClasspathEntry.CPE_SOURCE) 
							&& (path == generatedFolder.fullPath)]) {
						classPathEntries.add(JavaCore.newSourceEntry(generatedFolder.fullPath));
					}
					
					// Support JUnit 4
					if (!existingClasspath.exists[(entryKind === IClasspathEntry.CPE_CONTAINER) 
							&& (path == JUnitCore.JUNIT4_CONTAINER_PATH)]) {
						classPathEntries.add(JavaCore.newContainerEntry(JUnitCore.JUNIT4_CONTAINER_PATH));
					}
										
					setupMonitor.done();
					
					var seleniumLibMonitor = subMonitor.split(1);
					seleniumLibMonitor.taskName = "Adding Selenium libraries to Classpath"
										
					// Selenium Support Libs
					var supportFiles = SeleniumDependenciesProvider.getLibs(project,setupMonitor);
					supportFiles.forEach[ f | 
						if (!existingClasspath.exists[(entryKind === IClasspathEntry.CPE_LIBRARY) && (path == f)]) {
							classPathEntries.add(JavaCore.newLibraryEntry(f, null, null))		
						}
					]
					
					javaProject.setRawClasspath(classPathEntries, null);
					
					seleniumLibMonitor.done();
					
				}catch(Exception ex){
					ex.printStackTrace();
					lock.unlock();
					return Status.CANCEL_STATUS;
				}
				lock.unlock();
				return Status.OK_STATUS;
			}
			
		}
		
		setupJob.schedule();
		
	}
		
	
}
