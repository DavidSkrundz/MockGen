//
//  FileParser.swift
//  MockGen
//

import Regex
import Util

public struct FileParser {
	public static func parseFile(fileName: String, fileContents: String) -> [Protocol] {
		print("Processing: \(fileName)")
		let fileLines = FileParser.splitLines(fileContents)
		let trimmedLines = FileParser.trimWhitespace(fileLines)
		let filteredLines = FileParser.filterComments(trimmedLines)
		let protocolStrings = FileParser.findProtocolLines(filteredLines)
		return protocolStrings.map(Protocol.constructProtocol)
	}
	
	private static let lineSplitRegex = try! Regex(".+")
	private static func splitLines(_ string: String) -> [String] {
		return lineSplitRegex.match(string).map { $0.match }
	}
	
	private static let whitespaceTrimmingRegex = try! Regex("\\S+(?:.+\\S+)?")
	private static func trimWhitespace(_ strings: [String]) -> [String] {
		return strings.flatMap { whitespaceTrimmingRegex.match($0).first?.match }
	}
	
	private static let commentStrippingRegex = try! Regex("\\/\\/[^@]")
	private static func filterComments(_ strings: [String]) -> [String] {
		return strings.filter { commentStrippingRegex.match($0).count == 0 && $0 != "//" }
	}
	
	private static let attributeRegex = try! Regex("\\/\\/(\\@.+)")
	private static func findProtocolLines(_ strings: [String]) -> [[String]] {
		func findRestOfLines(_ generator: inout Generator<[String]>) -> [String] {
			var protocolLines = [String]()
			while let line = generator.next() {
				if line == "}" { break }
				protocolLines.append(line)
				if line.hasSuffix("{}") { break }
			}
			return protocolLines
		}
		
		var protocolStrings = [[String]]()
		var lineGenerator = strings.generator()
		while let line = lineGenerator.next() {
			guard let match = attributeRegex.match(line).first?.groups.first else { continue }
			switch match {
			case "@Mockable":
				protocolStrings += [findRestOfLines(&lineGenerator)]
			default: break
			}
		}
		return protocolStrings
	}
}
