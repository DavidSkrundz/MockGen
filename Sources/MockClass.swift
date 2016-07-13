//
//  Mock.swift
//  MockGen
//

let mockClass = [
"import XCTest",
"",
"class Mock {",
"\tprivate var accessLog = [String : [Any]]()",
"\t",
"\tfunc recordMethodCall(name: String, args: Any) {",
"\t\tself.accessLog[name] = (self.accessLog[name] ?? []) + [args]",
"\t}",
"}",
"",
"class Verifyable {",
"\tprivate var accessLog = [String : [Any]]()",
"\t",
"\tinit(accessLog: [String : [Any]]) {",
"\t\tself.accessLog = accessLog",
"\t}",
"\t",
"\tfunc verifyCalled(name: String) {",
"\t\tXCTAssertNil(self.accessLog[name])",
"\t}",
"\t",
"\tfunc verifyCalled(name: String, count: Int) {",
"\t\tXCTAssertEqual(count, self.accessLog[name]?.count)",
"\t}",
"\t",
"\tfunc verifyCalled(name: String, @noescape argsPredicate:  (args: Any) -> Bool) {",
"\t\tXCTAssertFalse(self.accessLog[name]?.map { argsPredicate(args: $0) }.contains(false) ?? true)",
"\t}",
"}",
].joined(separator: "\n")