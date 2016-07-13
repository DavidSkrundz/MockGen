//
//  Mock.swift
//  MockGen
//

@testable import LiveTest

import XCTest

class Mock {
	private var accessLog = [String : [Any]]()
	
	func recordMethodCall(name: String, args: Any) {
		self.accessLog[name] = (self.accessLog[name] ?? []) + [args]
	}
}

class Verifyable {
	private var accessLog = [String : [Any]]()
	
	init(accessLog: [String : [Any]]) {
		self.accessLog = accessLog
	}
	
	func verifyCalled(name: String) {
		XCTAssertNil(self.accessLog[name])
	}
	
	func verifyCalled(name: String, count: Int) {
		XCTAssertEqual(count, self.accessLog[name]?.count)
	}
	
	func verifyCalled(name: String, @noescape argsPredicate:  (args: Any) -> Bool) {
		XCTAssertFalse(self.accessLog[name]?.map { argsPredicate(args: $0) }.contains(false) ?? true)
	}
}

class MockDataProvider: Mock, DataProvider {
	var isConnectedGetOverride: () -> (Bool) = { false }
	var isConnected: Bool {
		get {
			self.recordMethodCall("isConnectedGet", args: ())
			return isConnectedGetOverride()
		}
	}
	
	var isActiveGetOverride: () -> (Bool) = { false }
	var isActiveSetOverride: (Bool) -> () = { _ in }
	var isActive: Bool {
		get {
			self.recordMethodCall("isActiveGet", args: ())
			return isActiveGetOverride()
		}
		set {
			self.recordMethodCall("isActiveSet", args: (newValue))
			return isActiveSetOverride(newValue)
		}
	}
	
	var getDataOverride: (fromURL: String) -> (String) = { (_) in "" }
	func getData(fromURL: String) -> String {
		self.recordMethodCall("getData", args: (fromURL))
		return getDataOverride(fromURL)
	}
}

class VerifyableDataProvider: Verifyable, DataProvider {
	func isConnectedGet() {
		self.verifyCalled("isConnectedGet")
	}
	
	func isConnectedGet(count: Int) {
		self.verifyCalled("isConnectedGet", count: count)
	}
	
	func isActiveGet() {
		self.verifyCalled("isActiveGet")
	}
	
	func isActiveGet(count: Int) {
		self.verifyCalled("isActiveGet", count: count)
	}
	
	func isActiveSet() {
		self.verifyCalled("isActiveSet")
	}
	
	func isActiveSet(count: Int) {
		self.verifyCalled("isActiveSet", count: count)
	}
	
	func isActiveSet(@noescape argsPredicate: (isActive: Bool) -> Bool) {
		return self.verifyCalled("isActiveSet") { args in
			guard let args = args as? (Bool) else { XCTFail("Argument tuple was of wrong type"); return false }
			return argsPredicate(isActive: args.0)
		}
	}
	
	func getData() {
		self.verifyCalled("getData")
	}
	
	func getData(count: Int) {
		self.verifyCalled("getData", count: count)
	}
	
	func getData(@noescape argsPredicate: (fromURL: String) -> Bool) {
		return self.verifyCalled("getData") { args in
			guard let args = args as? (String) else { XCTFail("Argument tuple was of wrong type"); return false }
			return argsPredicate(fromURL: args.0)
		}
	}
}

extension MockDataProvider {
	var verify: VerifyableDataProvider { return VerifyableDataProvider(accessLog: self.accessLog) }
}