//
//  VerifyGenerator.swift
//  MockGen
//

public struct VerifyGenerator {
	public static func generateVerifyClassConformingTo(_ `protocol`: Protocol) -> [String] {
		var classStrings = [String]()
		
		classStrings.append("class Verifyable\(`protocol`.name): Verifyable, \(`protocol`.name) {")
		
		for variable in `protocol`.variables {
			classStrings += generateVerifyFunction("\(variable.name)Get")
			classStrings += generateVerifyCount("\(variable.name)Get")
			if variable.hasSetter {
				classStrings += generateVerifyFunction("\(variable.name)Set")
				classStrings += generateVerifyCount("\(variable.name)Set")
				let function = Function(name: "\(variable.name)Set", arguments: [Argument(access: "", name: variable.name, type: variable.type)], returnType: "")
				classStrings += generateVerifyArguments(function)
			}
		}
		
		for function in `protocol`.functions {
			classStrings += generateVerifyFunction(function.name)
			classStrings += generateVerifyCount(function.name)
			if function.arguments.count > 0 {
				classStrings += generateVerifyArguments(function)
			}
		}
		
		if classStrings.last == "\t" { classStrings.removeLast() }
		classStrings.append("}")
		
		classStrings.append("")
		
		classStrings.append("extension Mock\(`protocol`.name) {")
		classStrings.append("\tvar verify: Verifyable\(`protocol`.name) { return Verifyable\(`protocol`.name)(accessLog: self.accessLog) }")
		classStrings.append("}")
		
		return classStrings
	}
	
	private static func generateVerifyFunction(_ name: String) -> [String] {
		return [
			"\tfunc \(name)() {",
			"\t\tself.verifyCalled(\"\(name)\")",
			"\t}",
			"\t",
		]
	}
	
	private static func generateVerifyCount(_ name: String) -> [String] {
		return [
			"\tfunc \(name)(count: Int) {",
			"\t\tself.verifyCalled(\"\(name)\", count: count)",
			"\t}",
			"\t",
		]
	}
	
	private static func generateVerifyArguments(_ function: Function) -> [String] {
		let functionArguments = function.arguments.map { "\($0.access): \($0.type)" }.joined(separator: ", ")
		let functionArgumentTypes = function.arguments.map { "\($0.type)" }.joined(separator: ", ")
		let functionArgumentCall = function.arguments.enumerated().map { "\($1.access): args.\($0)" }.joined(separator: ", ")
		return [
			"\tfunc \(function.name)(@noescape argsPredicate: (\(functionArguments)) -> Bool) {",
			"\t\treturn self.verifyCalled(\"\(function.name)\") { args in",
			"\t\t\tguard let args = args as? (\(functionArgumentTypes)) else { XCTFail(\"Argument tuple was of wrong type\"); return false }",
			"\t\t\treturn argsPredicate(\(functionArgumentCall))",
			"\t\t}",
			"\t}",
			"\t",
		]
	}
}
