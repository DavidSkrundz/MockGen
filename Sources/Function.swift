//
//  Function.swift
//  MockGen
//

public struct Function {
	public let name: String
	public let genericParameters: String
	public let arguments: [Argument]
	public let returnType: String
	
	init(name: String, genericParameters: String, arguments: [Argument], returnType: String) {
		self.name = name + arguments.map { "_\($0.access)" }.joined(separator: "")
		self.genericParameters = genericParameters
		self.arguments = arguments
		self.returnType = returnType != "" ? returnType : "Void"
	}
}
