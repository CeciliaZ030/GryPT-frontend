import Foundation

enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
}

struct Transaction: Identifiable {
    let id = UUID()
    let hash: String
    let from: String
    let to: String
    let value: String
    let timestamp: Date
    let status: TransactionStatus
    let explanation: String?
    
    // Additional data for specific contract calls
    let contractAddress: String?
    let functionName: String?
    let functionArgs: [String]?
} 