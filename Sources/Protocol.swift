//
//  Protocol.swift
//  MockGen
//

import Regex

public struct Protocol {
	public let name: String
	public let variables: [Variable]
	public let functions: [Function]
	public let subscripts: [Subscript]
	
	private static let shortProtocolRegex = try! Regex("protocol +(\\w+) *(?:\\: *class)? *\\{\\}")
	private static let longProtocolRegex = try! Regex("protocol +(\\w+) *(?:\\: *class)? *\\{")
	private static let whitespaceTrimmingRegex = try! Regex("\\S+(?:.+\\S+)?")
	private static let protocolVariableRegex = try! Regex("var +(\\w+) *\\: *((?:[\\w<\\[?:\\]>] ??)+) *\\{ *get *(set)? *?\\}")
	private static let protocolFunctionRegex = try! Regex("func +([\\w?]+)((?:<[\\w?]+>)?) *\\((?: *(\\w+.*[\\w<\\[?:\\]>]) *)?\\)(?: *\\-\\> *([\\w<\\[?:\\]>]+))?")
	private static let protocolFunctionArgumentsRegex = try! Regex("[^,]+")
	private static let protocolFunctionArgumentPartsRegex = try! Regex("(\\w+) *(\\w+)? *\\: *([\\w<\\[?:\\]>]+)")
	private static let protocolSubscriptRegex = try! Regex("subscript *\\((.+)\\) *-> *(\\S+) *\\{ *get *(set)? *?\\}")
	internal static func constructProtocol(_ protocolLines: [String]) -> Protocol {
		var protocolName = ""
		var variables = [Variable]()
		var functions = [Function]()
		var subscripts = [Subscript]()
		
		for line in protocolLines {
			if let shortProtocolMatch = shortProtocolRegex.match(line).first {
				protocolName = shortProtocolMatch.groups[0]
				break
			}
			
			if let longProtocolMatch = longProtocolRegex.match(line).first {
				protocolName = longProtocolMatch.groups[0]
			}
			
			if let protocolVariableMatch = protocolVariableRegex.match(line).first {
				let hasSetter = protocolVariableMatch.groups[2] != ""
				let pVar = Variable(name: protocolVariableMatch.groups[0], type: protocolVariableMatch.groups[1], hasSetter: hasSetter)
				variables.append(pVar)
				continue
			}
			
			if let protocolFunctionMatch = protocolFunctionRegex.match(line).first {
				var arguments = [Argument]()
				
				let pFuncArgs = protocolFunctionMatch.groups[2]
				for funcArgMatch in protocolFunctionArgumentsRegex.match(pFuncArgs) {
					guard let whitespaceOnlyArg = whitespaceTrimmingRegex.match(funcArgMatch.match).first else { continue }
					guard let argParts = protocolFunctionArgumentPartsRegex.match(whitespaceOnlyArg.match).first?.groups else { continue }
					let argument: Argument
					if argParts[1].isEmpty {
						argument = Argument(access: argParts[0], name: argParts[1], type: argParts[2])
					} else {
						argument = Argument(access: argParts[1], name: argParts[0], type: argParts[2])
					}
					arguments.append(argument)
				}
				
				functions.append(Function(name: protocolFunctionMatch.groups[0], genericParameters: protocolFunctionMatch.groups[1], arguments: arguments, returnType: protocolFunctionMatch.groups[3]))
				continue
			}
			
			if let protocolSubscriptMatch = protocolSubscriptRegex.match(line).first {
				let hasSetter = protocolSubscriptMatch.groups[2] != ""
				var arguments = [Argument]()
				for funcArgMatch in protocolFunctionArgumentsRegex.match(protocolSubscriptMatch.groups[0]) {
					guard let whitespaceOnlyArg = whitespaceTrimmingRegex.match(funcArgMatch.match).first else { continue }
					guard let argParts = protocolFunctionArgumentPartsRegex.match(whitespaceOnlyArg.match).first?.groups else { continue }
					let argument: Argument
					if argParts[1].isEmpty {
						argument = Argument(access: argParts[0], name: argParts[1], type: argParts[2])
					} else {
						argument = Argument(access: argParts[1], name: argParts[0], type: argParts[2])
					}
					arguments.append(argument)
				}
				subscripts.append(Subscript(arguments: arguments, returnType: protocolSubscriptMatch.groups[1], hasSetter: hasSetter))
			}
		}
		
		print("  Found: \(protocolName)")
		return Protocol(name: protocolName, variables: variables, functions: functions, subscripts: subscripts)
	}
	
	private init(name: String, variables: [Variable], functions: [Function], subscripts: [Subscript]) {
		self.name = name
		self.variables = variables
		self.functions = functions
		self.subscripts = subscripts
	}
}
