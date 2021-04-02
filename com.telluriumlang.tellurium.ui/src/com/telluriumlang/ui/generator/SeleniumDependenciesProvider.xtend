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
		"https://repo1.maven.org/maven2/com/google/guava/guava/23.6-jre/guava-23.6-jre.jar",
		"https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/3.11.0/okhttp-3.11.0.jar",
		"https://repo1.maven.org/maven2/com/squareup/okio/okio/1.14.0/okio-1.14.0.jar",
		"https://repo1.maven.org/maven2/net/bytebuddy/byte-buddy/1.8.15/byte-buddy-1.8.15.jar",
		"https://repo1.maven.org/maven2/org/apache/commons/commons-exec/1.3/commons-exec-1.3.jar",
		"https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.12.0/commons-lang3-3.12.0.jar",
		"https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.13/httpclient-4.5.13.jar",
		"https://repo1.maven.org/maven2/org/apache/httpcomponents/httpcore/4.4.13/httpcore-4.4.13.jar",
		"https://repo1.maven.org/maven2/org/apache/httpcomponents/httpmime/4.5.13/httpmime-4.5.13.jar",
		"https://repo1.maven.org/maven2/commons-io/commons-io/2.8.0/commons-io-2.8.0.jar",
		"https://repo1.maven.org/maven2/commons-codec/commons-codec/1.10/commons-codec-1.10.jar",
		"https://repo1.maven.org/maven2/commons-collections/commons-collections/3.2.1/commons-collections-3.2.1.jar",
		"https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar",
		"https://repo1.maven.org/maven2/commons-net/commons-net/3.8.0/commons-net-3.8.0.jar",
		"https://repo1.maven.org/maven2/org/apache/commons/commons-text/1.9/commons-text-1.9.jar",
		"https://repo1.maven.org/maven2/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar",
		"https://repo1.maven.org/maven2/xerces/xercesImpl/2.12.0/xercesImpl-2.12.0.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-api/3.141.59/selenium-api-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-chrome-driver/3.141.59/selenium-chrome-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-edge-driver/3.141.59/selenium-edge-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-firefox-driver/3.141.59/selenium-firefox-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-ie-driver/3.141.59/selenium-ie-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-opera-driver/3.0.0/selenium-opera-driver-3.0.0.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-remote-driver/3.141.59/selenium-remote-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-safari-driver/3.141.59/selenium-safari-driver-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/selenium-support/3.141.59/selenium-support-3.141.59.jar",
		"https://repo1.maven.org/maven2/org/seleniumhq/selenium/htmlunit-driver/2.48.0/htmlunit-driver-2.48.0.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/htmlunit/htmlunit/2.48.0/htmlunit-2.48.0.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/htmlunit/htmlunit-core-js/2.48.0/htmlunit-core-js-2.48.0.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/htmlunit/htmlunit-core-js/2.48.0/htmlunit-core-js-2.48.0.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/htmlunit/htmlunit-cssparser/1.7.0/htmlunit-cssparser-1.7.0.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/htmlunit/neko-htmlunit/2.48.0/neko-htmlunit-2.48.0.jar",
		"https://repo1.maven.org/maven2/xml-apis/xml-apis/1.4.01/xml-apis-1.4.01.jar",
		"https://repo1.maven.org/maven2/xalan/xalan/2.7.2/xalan-2.7.2.jar",
		"https://repo1.maven.org/maven2/xalan/serializer/2.7.2/serializer-2.7.2.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/nekohtml/nekohtml/1.9.22/nekohtml-1.9.22.jar",
		"https://repo1.maven.org/maven2/net/sourceforge/cssparser/cssparser/0.9.16/cssparser-0.9.16.jar",
		"https://repo1.maven.org/maven2/org/w3c/css/sac/1.3/sac-1.3.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/websocket/websocket-client/9.4.38.v20210224/websocket-client-9.4.38.v20210224.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util/9.4.38.v20210224/jetty-util-9.4.38.v20210224.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-io/9.4.38.v20210224/jetty-io-9.4.38.v20210224.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/websocket/websocket-common/9.4.38.v20210224/websocket-common-9.4.38.v20210224.jar",
		"https://repo1.maven.org/maven2/org/eclipse/jetty/websocket/websocket-api/9.4.38.v20210224/websocket-api-9.4.38.v20210224.jar",
		"https://repo1.maven.org/maven2/com/google/code/gson/gson/2.3.1/gson-2.3.1.jar",
		"https://repo1.maven.org/maven2/org/webbitserver/webbit/0.4.14/webbit-0.4.14.jar",
		"https://repo1.maven.org/maven2/io/netty/netty/3.5.2.Final/netty-3.5.2.Final.jar",
		"https://repo1.maven.org/maven2/com/shapesecurity/salvation2/3.0.0/salvation2-3.0.0.jar",
		"https://repo1.maven.org/maven2/org/brotli/dec/0.1.2/dec-0.1.2.jar"
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