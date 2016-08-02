//
//  FileWriter.swift
//  MockGen
//

import Foundation

public struct FileWriter {
	public static func write(_ string: String, to file: URL) {
		print("")
		print("Writing output to \(file.absoluteString)")
		try! string.write(to: file, atomically: true, encoding: .utf8)
	}
}
