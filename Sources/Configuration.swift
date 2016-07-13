//
//  Configuration.swift
//  MockGen
//

import Foundation

public struct Configuration {
	let outputFilePath: URL
	let projectName: String
	let additionalImports: [String]
	let typeMap: [String : String]
	
	init(fileName: String) {
		let bundlePath = Bundle.main.bundleURL
		let configFilePath = try! bundlePath.appendingPathComponent(fileName).appendingPathExtension("plist")
		
		if let configDict = NSDictionary(contentsOf: configFilePath) {
			self.outputFilePath = try! bundlePath.appendingPathComponent(configDict["RelativeOutputFilePath"] as! String)
			self.projectName = configDict["ProjectName"] as! String
			self.additionalImports = configDict["AdditionalImports"] as! [String]
			
			var loadedTypeMap = configDict["TypeMap"] as! [String : String]
			loadedTypeMap["Void"] = "()"
			
			self.typeMap = loadedTypeMap
		} else {
			fatalError("\(fileName).plist not found")
		}
	}
}
