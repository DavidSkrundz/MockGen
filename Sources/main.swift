//
//  main.swift
//  MockGen
//

let config = Configuration(fileName: "MockGen")

let swiftFileContents = FileLoader.findAndLoadSwiftFiles()

print("")
print("Processing Files...")
let protocols = swiftFileContents.flatMap(FileParser.parseFile)

let outputFileHeader = [
"//",
"//  \(config.outputFilePath.lastPathComponent)",
"//  MockGen",
"//",
"",
"@testable import \(config.projectName)",
].joined(separator: "\n")

let additionalImports = config.additionalImports
	.map { "import \($0)" }
	.joined(separator: "\n")

// mockClass = [...]

print("")
print("Generating Mocks...")
let protocolImplementation = protocols
	.map { MockGenerator.generateMockClassConformingTo($0, defaultValueDictionary: config.typeMap).joined(separator: "\n") }
	.joined(separator: "\n\n")

print("")
print("Generating Verifyables...")
let verifyableImplementation = protocols
	.map { VerifyGenerator.generateVerifyClassConformingTo($0).joined(separator: "\n") }
	.joined(separator: "\n")

let mockGenOutput = [outputFileHeader, additionalImports, mockClass, protocolImplementation, verifyableImplementation].joined(separator: "\n\n")

FileWriter.write(mockGenOutput, to: config.outputFilePath)

print("")
print("DONE!")
