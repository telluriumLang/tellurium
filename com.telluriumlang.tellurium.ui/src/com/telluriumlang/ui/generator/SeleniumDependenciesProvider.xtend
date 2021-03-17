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
		"https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.4/commons-lang3-3.4.jar",
		"https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.4.1/httpclient-4.4.1.jar",
		"https://repo1.maven.org/maven2/org/apache/httpcomponents/httpcore/4.4.1/httpcore-4.4.1.jar",
		"https://repo1.maven.org/maven2/org/apache/httpcomponents/httpmime/4.4.1/httpmime-4.4.1.jar",
		"https://repo1.maven.org/maven2/commons-io/commons-io/2.4/commons-io-2.4.jar",
		"https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar",
		"https://repo1.maven.org/maven2/commons-codec/commons-codec/1.10/commons-codec-1.10.jar",
		"https://repo1.maven.org/maven2/commons-collections/commons-collections/3.2.1/commons-collections-3.2.1.jar",
		"https://repo1.maven.org/maven2/xerces/xercesImpl/2.11.0/xercesImpl-2.11.0.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-api/3.141.59/selenium-api-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-chrome-driver/3.141.59/selenium-chrome-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-edge-driver/3.141.59/selenium-edge-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-firefox-driver/3.141.59/selenium-firefox-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-ie-driver/3.141.59/selenium-ie-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-opera-driver/3.141.59/selenium-opera-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-remote-driver/2.47.1/selenium-remote-driver-2.47.1.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-safari-driver/3.141.59/selenium-safari-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-support/3.141.59/selenium-support-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-htmlunit-driver/2.47.1/selenium-htmlunit-driver-2.47.1.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/htmlunit/htmlunit/2.17/htmlunit-2.17.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/htmlunit/htmlunit-core-js/2.17/htmlunit-core-js-2.17.jar",
		"https://repo1.maven.org/maven2/xml-apis/xml-apis/1.4.01/xml-apis-1.4.01.jar",
		"https://repo1.maven.org/maven2/xalan/xalan/2.7.2/xalan-2.7.2.jar",
		"https://repo1.maven.org/maven2/xalan/serializer/2.7.2/serializer-2.7.2.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/nekohtml/nekohtml/1.9.22/nekohtml-1.9.22.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/cssparser/cssparser/0.9.16/cssparser-0.9.16.jar",
		"https://repo1.maven.org/maven2/org/w3c/css/sac/1.3/sac-1.3.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/websocket/websocket-client/9.2.11.v20150529/websocket-client-9.2.11.v20150529.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util/9.2.11.v20150529/jetty-util-9.2.11.v20150529.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-io/9.2.11.v20150529/jetty-io-9.2.11.v20150529.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/websocket/websocket-common/9.2.11.v20150529/websocket-common-9.2.11.v20150529.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/websocket/websocket-api/9.2.11.v20150529/websocket-api-9.2.11.v20150529.jar",
		"https://repo1.maven.org/maven2/net/java/dev/jna/jna/4.1.0/jna-4.1.0.jar",
		"https://repo1.maven.org/maven2/net/java/dev/jna/jna-platform/4.1.0/jna-platform-4.1.0.jar",
		"https://repo1.maven.org/maven2/cglib/cglib-nodep/2.1_3/cglib-nodep-2.1_3.jar",
		"https://repo1.maven.org/maven2/com/google/code/gson/gson/2.3.1/gson-2.3.1.jar"
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