/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.generator

import com.telluriumlang.tellurium.AutomationTestSet
import com.telluriumlang.tellurium.DriverConfig
import com.telluriumlang.tellurium.DriverType
import com.telluriumlang.tellurium.DriverImplicityWait

class TestConfigurationGenerator {
	
	var definedDriver = false;
	
	def dispatch String generateProgram(AutomationTestSet dfg, TelluriumGeneratorContext ctx)'''
	
	private static WebDriver driver;
	private static Actions actionProvider;
	
	@Before
	public void setup() {
		«dfg.testConfig.map[ e | generateProgram(e,ctx)].join('\n')»
		«IF !definedDriver»
		if(driver == null){
			driver = new «this.getDriverName(DriverType.HTML_UNIT, ctx)»;
		}
		«ENDIF»
		actionProvider = new Actions(driver);
	}
	'''
	
	def dispatch String generateProgram(DriverConfig dfg, TelluriumGeneratorContext ctx)'''
	if(driver == null){
		driver = new «this.getDriverName(dfg.type,ctx)»;
	}
	'''
	
	def String getDriverName(DriverType type,TelluriumGeneratorContext ctx){
		definedDriver = true;
		if(type == DriverType.CHROME){
			ctx.importList.add("org.openqa.selenium.chrome.ChromeDriver");
			return "ChromeDriver()";
		}else if(type == DriverType.IE){
			ctx.importList.add("org.openqa.selenium.ie.InternetExplorerDriver");
			return "InternetExplorerDriver()";
		}else if(type == DriverType.EDGE){
			ctx.importList.add("org.openqa.selenium.edge.EdgeDriver");
			return "EdgeDriver()";
		}else if(type == DriverType.FIREFOX){
			ctx.importList.add("org.openqa.selenium.firefox.FirefoxDriver");
			return "FirefoxDriver()";
		}else if(type == DriverType.HTML_UNIT){
			ctx.importList.add("org.openqa.selenium.htmlunit.HtmlUnitDriver");
			return "HtmlUnitDriver(true)";
		}else if(type == DriverType.SAFARI){
			ctx.importList.add("org.openqa.selenium.safari.SafariDriver");
			return "SafariDriver()";
		}
	}
	
	def dispatch String generateProgram(DriverImplicityWait dfg, TelluriumGeneratorContext ctx)'''
	driver.manage().timeouts().implicitlyWait(«dfg.waitsec», TimeUnit.SECONDS);
	'''
	
}