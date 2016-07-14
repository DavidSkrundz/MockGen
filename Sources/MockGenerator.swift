//
//  MockGenerator.swift
//  MockGen
//

public struct MockGenerator {
	private static let recordMethodCall = "self.recordMethodCall"
	public static func generateMockClassConformingTo(_ `protocol`: Protocol, defaultValueDictionary: [String : String]) -> [String] {
		print("Generating: \(`protocol`.name)")
		
		var classStrings = [String]()
		
		classStrings.append("class Mock\(`protocol`.name): Mock, \(`protocol`.name) {")
		
		for variable in `protocol`.variables {
			guard let defaultValue = defaultValueDictionary[variable.type] else { fatalError("\(variable.type) does not have a known defalt value") }
			classStrings.append("\tvar \(variable.name)GetOverride: () -> (\(variable.type)) = { \(defaultValue) }")
			if variable.hasSetter {
				classStrings.append("\tvar \(variable.name)SetOverride: (\(variable.type)) -> () = { _ in }")
			}
			
			classStrings.append("\tvar \(variable.name): \(variable.type) {")
			classStrings.append("\t\tget {")
			classStrings.append("\t\t\t\(recordMethodCall)(\"\(variable.name)Get\", args: ())")
			classStrings.append("\t\t\treturn \(variable.name)GetOverride()")
			classStrings.append("\t\t}")
			if variable.hasSetter {
				classStrings.append("\t\tset {")
				classStrings.append("\t\t\t\(recordMethodCall)(\"\(variable.name)Set\", args: (newValue))")
				classStrings.append("\t\t\treturn \(variable.name)SetOverride(newValue)")
				classStrings.append("\t\t}")
			}
			classStrings.append("\t}")
			classStrings.append("\t")
		}
		
		for function in `protocol`.functions {
			if !function.genericParameters.isEmpty {
				classStrings.append("\tERROR - Copy implementation of \(function.overrideName) here")
				continue
			}
			
			guard let defaultValue = defaultValueDictionary[function.returnType] else { fatalError("\(function.returnType) does not have a known defalt value") }
			let closureDefArguments = function.arguments.map { "\($0.access): \($0.type)" }.joined(separator: ", ")
			let functionArguments = function.arguments.map { ($0.name.isEmpty ? "" : "\($0.name) ") + "\($0.access): \($0.type)" }.joined(separator: ", ")
			let closureArguments = function.arguments.map { _ in "_" }.joined(separator: ", ")
			let argumentList = function.arguments.map { "\($0.access)" }.joined(separator: ", ")
			let argumentCallList = function.arguments.map { "\($0.access): \($0.access)" }.joined(separator: ", ")
			classStrings.append("\tvar \(function.overrideName)_Override: (\(closureDefArguments)) -> \(function.returnType) = { (\(closureArguments)) in \(defaultValue) }")
			classStrings.append("\tfunc \(function.name)(\(functionArguments)) -> \(function.returnType) {")
			classStrings.append("\t\t\(recordMethodCall)(\"\(function.overrideName)\", args: (\(argumentList)))")
			classStrings.append("\t\treturn \(function.overrideName)_Override(\(argumentCallList))")
			classStrings.append("\t}")
			classStrings.append("\t")
		}
		
		for `subscript` in `protocol`.subscripts {
			guard let defaultValue = defaultValueDictionary[`subscript`.returnType] else { fatalError("\(`subscript`.returnType) does not have a known defalt value") }
			let closureDefArguments = `subscript`.arguments.map { "\($0.access): \($0.type)" }.joined(separator: ", ")
			let closureArguments = `subscript`.arguments.map { _ in "_" }.joined(separator: ", ")
			let overrideName = `subscript`.arguments.map { "_\($0.access)" }.joined(separator: "")
			let argumentList = `subscript`.arguments.map { "\($0.access)" }.joined(separator: ", ")
			let subscriptArguments = `subscript`.arguments.map { ($0.name.isEmpty ? "" : "\($0.name) ") + "\($0.access): \($0.type)" }.joined(separator: ", ")
			let argumentCallList = `subscript`.arguments.map { "\($0.access): \($0.access)" }.joined(separator: ", ")
			classStrings.append("\tvar subscript\(overrideName)_GetOverride: (\(closureDefArguments)) -> \(`subscript`.returnType) = { \(closureArguments) in \(defaultValue) }")
			if `subscript`.hasSetter {
				classStrings.append("\tvar subscript\(overrideName)_SetOverride: (\(closureDefArguments), newValue: \(`subscript`.returnType)) -> Void = { \(closureArguments), _ in }")
			}
			classStrings.append("\tsubscript (\(subscriptArguments)) -> \(`subscript`.returnType) {")
			classStrings.append("\t\tget {")
			classStrings.append("\t\t\t\(recordMethodCall)(\"subscriptGet\(overrideName)\", args: (\(argumentList)))")
			classStrings.append("\t\t\treturn subscript\(overrideName)_GetOverride(\(argumentCallList))")
			classStrings.append("\t\t}")
			if `subscript`.hasSetter  {
				classStrings.append("\t\tset {")
				classStrings.append("\t\t\t\(recordMethodCall)(\"subscriptSet\(overrideName)\", args: (\(argumentList), newValue))")
				classStrings.append("\t\t\treturn subscript\(overrideName)_SetOverride(\(argumentCallList), newValue: newValue)")
				classStrings.append("\t\t}")
			}
			classStrings.append("\t}")
			classStrings.append("\t")
		}
		
		if classStrings.last == "\t" { classStrings.removeLast() }
		classStrings.append("}")
		
		return classStrings
	}
}
