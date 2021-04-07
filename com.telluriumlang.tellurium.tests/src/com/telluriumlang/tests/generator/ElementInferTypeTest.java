package com.telluriumlang.tests.generator;

import org.junit.Assert;
import org.junit.Test;

import com.telluriumlang.generator.ElementSelectorGenerator;

public class ElementInferTypeTest {

	@Test
	public void test() {
		// By.id("id")
		Assert.assertEquals("By.id(\"id\")", ElementSelectorGenerator.inferSelector("#id"));
		
		// By.tagName("a")
		Assert.assertEquals("By.tagName(\"a\")", ElementSelectorGenerator.inferSelector("a"));
		
		// By.className("...")
		Assert.assertEquals("By.className(\"class\")", ElementSelectorGenerator.inferSelector(".class"));
		
		// By.name("...")
		Assert.assertEquals("By.name(\"name\")", ElementSelectorGenerator.inferSelector("name = 'name'"));
		Assert.assertEquals("By.name(\"\")", ElementSelectorGenerator.inferSelector("name = ''"));
		
		// By.xpath("...")
		Assert.assertEquals("By.xpath(\"/html\")", ElementSelectorGenerator.inferSelector("/html"));
		Assert.assertEquals("By.xpath(\"//*[@id=\"post_body\"]/p[1]\")", ElementSelectorGenerator.inferSelector("//*[@id=\"post_body\"]/p[1]"));
		
		// By.cssSelector("name")
		Assert.assertEquals("By.cssSelector(\"#post_body > p:nth-child(1)\")", ElementSelectorGenerator.inferSelector("#post_body > p:nth-child(1)"));
		
	}
	
}
