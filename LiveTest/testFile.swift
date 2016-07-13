//@Mockable
protocol DataProvider {
	var isConnected: Bool { get }
	var isActive: Bool { get set }
	
	func getData(fromURL: String) -> String
}
