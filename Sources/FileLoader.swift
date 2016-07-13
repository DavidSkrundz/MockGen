//
//  FileLoader.swift
//  MockGen
//

import Foundation
import Regex

public struct FileLoader {
	private static let attributeRegex = try! Regex("/\\/\\/\\@/")
	public static func findAndLoadSwiftFiles() -> [(String, String)] {
		let swiftFilePaths = findFiles(".swift")
		
		print("")
		print("Scanning files for attributes...")
		return swiftFilePaths
			.flatMap { try? (String(contentsOfFile: $0), $0) }
			.filter { (fileContents, filePath) -> Bool in
				print("Checking: \(NSURL(string: filePath)?.lastPathComponent ?? "")")
				if attributeRegex.match(fileContents).isEmpty { return false }
				print("Found: \(NSURL(string: filePath)!.lastPathComponent!)")
				return true
			}
			.map { ($0.1, $0.0) }
	}
	
	private static func findFiles(_ `extension`: String) -> [String] {
		print("")
		print("Searching for \(`extension`) files...")
		
		var filePaths = [String]()
		
		let basePath = Bundle.main().bundlePath
		let fileManager = FileManager.default()
		
		var pathsToCheck = [basePath]
		while !pathsToCheck.isEmpty {
			let path = pathsToCheck.remove(at: 0)
			
			var isDirectory: ObjCBool = false
			guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else { continue }
			
			if isDirectory {
				pathsToCheck += ((try? fileManager.contentsOfDirectory(atPath: path)) ?? [])
					.map { "\(path)/\($0)" }
			} else {
				if path.hasSuffix(`extension`) {
					filePaths.append(path)
					print("Found: \(path)")
				}
			}
		}
		
		return filePaths
	}
}
