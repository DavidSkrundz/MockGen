//
//  Configuration.swift
//  MockGen
//

import Foundation

public struct Configuration {
	let outputFilePath: URL
	let projectName: String
	let typeMap: [String : String]
	
	init(fileName: String) {
		let bundlePath = Bundle.main().bundleURL
		let configFilePath = try! bundlePath.appendingPathComponent(fileName).appendingPathExtension("plist")
		
		if let configDict = NSDictionary(contentsOf: configFilePath) {
			self.outputFilePath = try! bundlePath.appendingPathComponent(configDict["RelativeOutputFilePath"] as! String)
			self.projectName = configDict["ProjectName"] as! String
			self.typeMap = configDict["TypeMap"] as! [String : String]
		} else {
			fatalError("\(fileName).plist not found")
		}
	}
}
