import Foundation
import Combine
import LocalAuthentication

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    var transactionPackage: TransactionPackage?
}

struct TransactionPackage: Decodable {
    let actions: [TransactionAction]
    let totalGasEstimate: String
    let totalValue: String
}

struct TransactionAction: Identifiable, Decodable {
    let id = UUID()
    let contractAddress: String?
    let functionName: String?
    let functionArgs: [String]?
    let value: String
    let explanation: String
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isProcessing = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: APIService
    private var authViewModel: AuthViewModel
    
    init(apiService: APIService, authViewModel: AuthViewModel) {
        self.apiService = apiService
        self.authViewModel = authViewModel
        
        // Add welcome message
        addSystemMessage("👋 Hello! I'm your crypto assistant. You can ask me to perform crypto actions like \"Swap 0.1 ETH to USDC on Uniswap\" or \"Send 50 USDC to vitalik.eth\"")
    }
    
    // Method to update the authViewModel reference to use the shared instance
    func updateAuthViewModel(_ viewModel: AuthViewModel) {
        self.authViewModel = viewModel
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            content: inputText,
            isUser: true,
            timestamp: Date(),
            transactionPackage: nil
        )
        
        messages.append(userMessage)
        
        let userInput = inputText
        inputText = ""
        
        processUserMessage(userInput)
    }
    
    private func processUserMessage(_ message: String) {
        guard let walletAddress = authViewModel.walletAddress else {
            addSystemMessage("⚠️ Please connect your wallet first")
            return
        }
        
        isProcessing = true
        
        // Call the backend API to process the message
        apiService.processMessage(message: message, walletAddress: walletAddress)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isProcessing = false
                    if case .failure(let error) = completion {
                        self.error = error.localizedDescription
                        self.addSystemMessage("❌ Error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { response in
                    if let package = response.transactionPackage {
                        // Create a message with the transaction package
                        let message = ChatMessage(
                            content: response.explanation,
                            isUser: false,
                            timestamp: Date(),
                            transactionPackage: package
                        )
                        self.messages.append(message)
                    } else {
                        // Regular response without a transaction
                        self.addSystemMessage(response.explanation)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func approveTransaction(_ transaction: TransactionPackage) {
        // Authenticate with Face ID before signing the transaction
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Confirm transaction with Face ID"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.signAndSubmitTransaction(transaction)
                    } else {
                        self.error = authError?.localizedDescription ?? "Authentication failed"
                        self.addSystemMessage("❌ Transaction cancelled: authentication failed")
                    }
                }
            }
        } else {
            self.error = error?.localizedDescription ?? "Face ID not available"
            self.addSystemMessage("❌ Transaction cancelled: Face ID not available")
        }
    }
    
    private func signAndSubmitTransaction(_ transaction: TransactionPackage) {
        // In a real app, sign the transaction with the private key from Keychain
        // and submit it to the blockchain. This is a placeholder implementation.
        isProcessing = true
        
        // Simulate API call to submit transaction
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isProcessing = false
            
            // Simulate successful transaction
            let txHash = "0x" + String((0..<64).map { _ in "0123456789abcdef".randomElement()! })
            self.addSystemMessage("✅ Transaction submitted! Hash: \(txHash)")
        }
    }
    
    private func addSystemMessage(_ content: String) {
        let message = ChatMessage(
            content: content,
            isUser: false,
            timestamp: Date(),
            transactionPackage: nil
        )
        messages.append(message)
    }
} 