package com.telluriumlang.ui.generator

import java.io.BufferedInputStream
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.net.URL
import java.util.List

import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.SubMonitor

class SeleniumDependenciesProvider {
	
	
	protected static val LIB_URL_LIST = #[
		"https://repo1.maven.org/maven2/com/google/guava/guava/25.0-jre/guava-25.0-jre.jar",
		"https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/3.11.0/okhttp-3.11.0.jar",
		"https://repo1.maven.org/maven2/com/squareup/okio/okio/1.14.0/okio-1.14.0.jar",
		"https://repo1.maven.org/maven2/net/bytebuddy/byte-buddy/1.8.15/byte-buddy-1.8.15.jar",
		"https://repo1.maven.org/maven2/org/apache/commons/commons-exec/1.3/commons-exec-1.3.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-api/3.141.59/selenium-api-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-chrome-driver/3.141.59/selenium-chrome-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-edge-driver/3.141.59/selenium-edge-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-firefox-driver/3.141.59/selenium-firefox-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-ie-driver/3.141.59/selenium-ie-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-opera-driver/3.141.59/selenium-opera-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-remote-driver/3.141.59/selenium-remote-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-safari-driver/3.141.59/selenium-safari-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-support/3.141.59/selenium-support-3.141.59.jar"
	];
	
	def static List<IPath> getLibs(IProject project,SubMonitor subMonitor){
		val folder = project.getFolder(new Path("selenium-support"));
		if(!folder.exists){
			folder.create(true,false,null);
		}
		LIB_URL_LIST.map[x | download(x, project, subMonitor.split(1))]
	}
	
	def static private IPath download(String url, IProject project, SubMonitor subMonitor ){
		subMonitor.taskName = "Downloading " + url;
		var fileName = url.split("/").last
		var file = project.getFile(new Path("selenium-support/"+fileName));
		if(file.exists){
			subMonitor.done();
			return file.fullPath
		}
		var baos = new ByteArrayOutputStream();
		
		var in = new BufferedInputStream(new URL(url).openStream());
		try {
			try {
				var buffer = newByteArrayOfSize(1024);
				var readBytes = -1;
				while ((readBytes = in.read(buffer)) != -1) {
					baos.write(buffer, 0, readBytes);
				}
			} finally {
				baos.close();
			}
		} finally {
			in.close();
		}
		var source = new ByteArrayInputStream(baos.toByteArray);
		file.create(source, IResource.NONE, null);
		subMonitor.done();
		return file.fullPath
	}
	
}