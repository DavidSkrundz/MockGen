//
//  Function.swift
//  MockGen
//

public struct Function {
	public let name: String
	public let arguments: [Argument]
	public let returnType: String
	
	init(name: String, arguments: [Argument], returnType: String) {
		self.name = name + arguments.map { "_\($0.access)" }.joined(separator: "")
		self.arguments = arguments
		self.returnType = returnType != "" ? returnType : "Void"
	}
}
