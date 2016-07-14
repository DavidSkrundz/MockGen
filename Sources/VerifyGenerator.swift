//
//  VerifyGenerator.swift
//  MockGen
//

public struct VerifyGenerator {
	public static func generateVerifyClassConformingTo(_ `protocol`: Protocol) -> [String] {
		var classStrings = [String]()
		
		classStrings.append("class Verifyable\(`protocol`.name): Verifyable {")
		
		for variable in `protocol`.variables {
			classStrings += generateVerifyFunction("\(variable.name)Get")
			classStrings += generateVerifyCount("\(variable.name)Get")
			if variable.hasSetter {
				classStrings += generateVerifyFunction("\(variable.name)Set")
				classStrings += generateVerifyCount("\(variable.name)Set")
				let function = Function(name: "\(variable.name)Set", genericParameters: "", arguments: [Argument(access: variable.name, name: "", type: variable.type)], returnType: "")
				classStrings += generateVerifyArguments(function)
			}
		}
		
		for function in `protocol`.functions {
			if !function.genericParameters.isEmpty {
				classStrings.append("\tERROR - Copy implementation of \(function.overrideName) here")
				continue
			}
			
			classStrings += generateVerifyFunction(function.overrideName)
			classStrings += generateVerifyCount(function.overrideName)
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
		classStrings.append("")
		
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
		var strings = [
			"\tfunc \(function.overrideName)(@noescape argsPredicate: (\(functionArguments)) -> Bool) {",
			"\t\treturn self.verifyCalled(\"\(function.overrideName)\") { args in",
			"\t\t\tguard let args = args as? (\(functionArgumentTypes)) else { XCTFail(\"Argument tuple was of wrong type\"); return false }",
		]
		if function.arguments.count == 1 {
			strings.append("\t\t\treturn argsPredicate(\(function.arguments[0].access): args)")
		} else {
			strings.append("\t\t\treturn argsPredicate(\(functionArgumentCall))")
		}
		strings += [
			"\t\t}",
			"\t}",
			"\t",
		]
		return strings
	}
}
