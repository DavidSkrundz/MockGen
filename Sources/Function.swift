//
//  Function.swift
//  MockGen
//

public struct Function {
	public let overrideName: String
	public let name: String
	public let genericParameters: String
	public let arguments: [Argument]
	public let returnType: String
	
	init(name: String, genericParameters: String, arguments: [Argument], returnType: String) {
		self.overrideName = name + arguments.map { "_\($0.access)" }.joined(separator: "")
		self.name = name
		self.genericParameters = genericParameters
		self.arguments = arguments
		self.returnType = returnType != "" ? returnType : "Void"
	}
}
