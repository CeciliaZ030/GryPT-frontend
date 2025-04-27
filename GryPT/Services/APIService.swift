import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String)
    case unknown
}

struct MessageResponse: Decodable {
    let explanation: String
    let transactionPackage: TransactionPackage?
}

class APIService {
    private let baseURL: URL
    private let session: URLSession
    
    init(baseURLString: String, session: URLSession = .shared) {
        self.baseURL = URL(string: baseURLString)!
        self.session = session
    }
    
    func processMessage(message: String, walletAddress: String) -> AnyPublisher<MessageResponse, APIError> {
        let endpoint = baseURL.appendingPathComponent("api/process-message")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "message": message,
            "walletAddress": walletAddress
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            return Fail(error: .networkError(error)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<MessageResponse, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: .unknown).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                    return Fail(error: .serverError(httpResponse.statusCode, message)).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: MessageResponse.self, decoder: JSONDecoder())
                    .mapError { APIError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // Simulate API responses for development/testing
    func simulateProcessMessage(message: String, walletAddress: String) -> AnyPublisher<MessageResponse, APIError> {
        // For testing/development when the backend is not available
        let lowercasedMessage = message.lowercased()
        
        if lowercasedMessage.contains("swap") && (lowercasedMessage.contains("eth") || lowercasedMessage.contains("usdc")) {
            // Simulate a swap transaction
            let action = TransactionAction(
                contractAddress: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", // Uniswap Router
                functionName: "swapExactTokensForTokens",
                functionArgs: ["100000000000000000", "95000000", "[0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48]", walletAddress, "1717811281"],
                value: "0",
                explanation: "Swap 0.1 ETH for approximately 95 USDC"
            )
            
            let package = TransactionPackage(
                actions: [action],
                totalGasEstimate: "0.002 ETH",
                totalValue: "0.1 ETH"
            )
            
            let response = MessageResponse(
                explanation: "I'll swap 0.1 ETH for USDC on Uniswap. Here's what will happen:\n\n1. Approve Uniswap Router to use your ETH\n2. Swap ETH to USDC through the Uniswap V2 Router\n\nEstimated gas cost: 0.002 ETH\nTotal value: 0.1 ETH\n\nPlease review and approve with Face ID.",
                transactionPackage: package
            )
            
            return Just(response)
                .setFailureType(to: APIError.self)
                .delay(for: .seconds(1), scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
        } else {
            // Simulate a regular response with no transaction
            let response = MessageResponse(
                explanation: "I understand you want to \"\(message)\". To execute this transaction, I need more specific details. Could you specify the token amounts and platforms?",
                transactionPackage: nil
            )
            
            return Just(response)
                .setFailureType(to: APIError.self)
                .delay(for: .seconds(1), scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
} 
