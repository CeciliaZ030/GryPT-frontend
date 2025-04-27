import Foundation
import Combine

enum RPCError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case jsonRPCError(code: Int, message: String)
}

class RPCService {
    private let rpcURL: URL
    private let session: URLSession
    
    init(rpcURLString: String, session: URLSession = .shared) {
        self.rpcURL = URL(string: rpcURLString)!
        self.session = session
    }
    
    // Get ETH balance for an address
    func getEthBalance(address: String) -> AnyPublisher<Double, RPCError> {
        let params = [address, "latest"]
        return makeRPCCall(method: "eth_getBalance", params: params)
            .tryMap { result -> Double in
                guard let hexString = result as? String else {
                    throw RPCError.invalidResponse
                }
                
                // Convert hex string to decimal
                let hexWithoutPrefix = hexString.hasPrefix("0x") ? String(hexString.dropFirst(2)) : hexString
                guard let value = UInt64(hexWithoutPrefix, radix: 16) else {
                    throw RPCError.invalidResponse
                }
                
                // Convert to ETH (divide by 10^18)
                return Double(value) / pow(10, 18)
            }
            .mapError { error -> RPCError in
                if let rpcError = error as? RPCError {
                    return rpcError
                }
                return RPCError.invalidResponse
            }
            .eraseToAnyPublisher()
    }
    
    // Get ERC-20 token balance for an address
    func getERC20Balance(address: String, contractAddress: String, decimals: Int) -> AnyPublisher<Double, RPCError> {
        // Encode the balanceOf function call for the ERC-20 contract
        // balanceOf function signature: balanceOf(address) -> uint256
        // The ABI encoding for the function is: keccak256("balanceOf(address)") -> first 4 bytes: 0x70a08231
        let functionSelector = "0x70a08231"
        
        // Pad the address to 32 bytes (remove 0x prefix, then left-pad with zeros)
        let paddedAddress = String(repeating: "0", count: 64 - (address.hasPrefix("0x") ? address.count - 2 : address.count)) + (address.hasPrefix("0x") ? String(address.dropFirst(2)) : address)
        
        let data = functionSelector + paddedAddress
        
        let params: [Any] = [
            ["to": contractAddress, "data": data],
            "latest"
        ]
        
        return makeRPCCall(method: "eth_call", params: params)
            .tryMap { result -> Double in
                guard let hexString = result as? String else {
                    throw RPCError.invalidResponse
                }
                
                // Convert hex string to decimal
                let hexWithoutPrefix = hexString.hasPrefix("0x") ? String(hexString.dropFirst(2)) : hexString
                guard let value = UInt64(hexWithoutPrefix, radix: 16) else {
                    throw RPCError.invalidResponse
                }
                
                // Return the raw value (will be divided by 10^decimals in the ViewModel)
                return Double(value)
            }
            .mapError { error -> RPCError in
                if let rpcError = error as? RPCError {
                    return rpcError
                }
                return RPCError.invalidResponse
            }
            .eraseToAnyPublisher()
    }
    
    // Generic JSON-RPC call
    private func makeRPCCall(method: String, params: [Any]) -> AnyPublisher<Any, RPCError> {
        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": method,
            "params": params,
            "id": 1
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            return Fail(error: .networkError(error)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .mapError { RPCError.networkError($0) }
            .tryMap { data, response -> Any in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw RPCError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw RPCError.invalidResponse
                }
                
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                if let error = json?["error"] as? [String: Any],
                   let code = error["code"] as? Int,
                   let message = error["message"] as? String {
                    throw RPCError.jsonRPCError(code: code, message: message)
                }
                
                guard let result = json?["result"] else {
                    throw RPCError.invalidResponse
                }
                
                return result
            }
            .mapError { error -> RPCError in
                if let rpcError = error as? RPCError {
                    return rpcError
                }
                return RPCError.invalidResponse
            }
            .eraseToAnyPublisher()
    }
    
    // Get test data for development without a real RPC connection
    func getTestEthBalance(address: String) -> AnyPublisher<Double, RPCError> {
        return Just(1.5) // 1.5 ETH
            .setFailureType(to: RPCError.self)
            .delay(for: .seconds(1), scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func getTestERC20Balance(address: String, contractAddress: String, decimals: Int) -> AnyPublisher<Double, RPCError> {
        var balance: Double
        
        switch contractAddress.lowercased() {
        case "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48": // USDC
            balance = 1250.0 * pow(10, Double(decimals)) // 1,250 USDC
        case "0xdac17f958d2ee523a2206206994597c13d831ec7": // USDT
            balance = 725.0 * pow(10, Double(decimals)) // 725 USDT
        case "0x6b175474e89094c44da98b954eedeac495271d0f": // DAI
            balance = 500.0 * pow(10, Double(decimals)) // 500 DAI
        default:
            balance = 0
        }
        
        return Just(balance)
            .setFailureType(to: RPCError.self)
            .delay(for: .seconds(1), scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
} 