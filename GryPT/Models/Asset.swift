import Foundation

struct Asset: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let balance: Double
    let decimals: Int
    let contractAddress: String?
    let logoURL: URL?
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        
        let divisor = pow(10.0, Double(decimals))
        let value = balance / divisor
        
        return formatter.string(from: NSNumber(value: value)) ?? "0.00"
    }
} 