/*
 * Tellurium - A DSL for automation testing
 */
package com.telluriumlang.validation

class TelluriumErrorTypes {
	
	public static val String DUPLICATED_DRIVER_CFG = "DUPLICATED_DRIVER_CFG"; 
	public static val String DUPLICATED_GET_INFO_TARGET = "DUPLICATED_GET_INFO_TARGET"; 
	public static val String NO_GET_INFO_TARGET = "NO_GET_INFO_TARGET";
	public static val String GET_INFO_TARGET_INVALID = "GET_INFO_TARGET_INVALID"; 
	public static val String GET_INFO_WINDOW_INVALID = "GET_INFO_WINDOW_INVALID"; 
	public static val String MOUSE_MOVE_WITHOUT_INSTRUCTION = "MOUSE_MOVE_WITHOUT_INSTRUCTION"; 
	public static val String STATEMENT_AFTER_QUIT = "STATEMENT_AFTER_QUIT"; 
	public static val String DUPLICATED_QUIT = "DUPLICATED_QUIT"; 
	public static val String CONFLICT_WITH_JAVA_KEYWORD = "CONFLICT_WITH_JAVA_KEYWORD";
	public static val String DUPLICATED_NAME = "DUPLICATED_NAME"; 
	public static val String UNUSED_VAR = "UNUSED_VAR"; 
}