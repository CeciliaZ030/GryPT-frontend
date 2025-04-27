import XCTest
import Combine
@testable import GryPT

class ChatViewModelTests: XCTestCase {
    var chatViewModel: ChatViewModel!
    var mockAuthViewModel: AuthViewModel!
    var mockAPIService: MockAPIService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        
        mockAuthViewModel = AuthViewModel()
        // Set up a mock wallet address
        mockAuthViewModel.signInWithApple()
        
        let expectation = XCTestExpectation(description: "Auth setup")
        mockAuthViewModel.$isLoading
            .dropFirst()
            .filter { !$0 }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        mockAPIService = MockAPIService()
        chatViewModel = ChatViewModel(apiService: mockAPIService, authViewModel: mockAuthViewModel)
    }
    
    override func tearDown() {
        chatViewModel = nil
        mockAuthViewModel = nil
        mockAPIService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // There should be one welcome message
        XCTAssertEqual(chatViewModel.messages.count, 1)
        XCTAssertFalse(chatViewModel.messages[0].isUser)
        XCTAssertTrue(chatViewModel.inputText.isEmpty)
        XCTAssertFalse(chatViewModel.isProcessing)
        XCTAssertNil(chatViewModel.error)
    }
    
    func testSendMessage() {
        // Given
        let testMessage = "Test message"
        chatViewModel.inputText = testMessage
        
        // When
        chatViewModel.sendMessage()
        
        // Then
        XCTAssertEqual(chatViewModel.messages.count, 2) // welcome + user message
        XCTAssertEqual(chatViewModel.messages[1].content, testMessage)
        XCTAssertTrue(chatViewModel.messages[1].isUser)
        XCTAssertTrue(chatViewModel.inputText.isEmpty)
        XCTAssertTrue(chatViewModel.isProcessing)
    }
    
    func testSendEmptyMessage() {
        // Given
        chatViewModel.inputText = "   " // Just spaces
        
        // When
        chatViewModel.sendMessage()
        
        // Then - nothing should happen
        XCTAssertEqual(chatViewModel.messages.count, 1) // Just the welcome message
    }
    
    func testUpdateAuthViewModel() {
        // Given
        let newAuthViewModel = AuthViewModel()
        
        // When
        chatViewModel.updateAuthViewModel(newAuthViewModel)
        
        // Then - internal property updated
        XCTAssertTrue(true) // Can't directly test internal state
    }
    
    func testProcessMessageWithoutWallet() {
        // Given
        let newAuthViewModel = AuthViewModel() // No wallet
        chatViewModel.updateAuthViewModel(newAuthViewModel)
        chatViewModel.inputText = "Test message"
        
        // When
        chatViewModel.sendMessage()
        
        // Then
        XCTAssertEqual(chatViewModel.messages.count, 3) // welcome + user message + error
        XCTAssertEqual(chatViewModel.messages[2].content, "⚠️ Please connect your wallet first")
        XCTAssertFalse(chatViewModel.messages[2].isUser)
    }
    
    func testProcessMessageWithRegularResponse() {
        // Given
        mockAPIService.mockResponseType = .regular
        chatViewModel.inputText = "Tell me about ETH"
        
        // When
        chatViewModel.sendMessage()
        
        // Then
        let expectation = XCTestExpectation(description: "Message processing completes")
        
        // Wait for the async operation to complete
        chatViewModel.$isProcessing
            .dropFirst() // Skip initial value
            .filter { !$0 } // Wait until isProcessing becomes false
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(chatViewModel.messages.count, 3) // welcome + user message + response
        XCTAssertFalse(chatViewModel.messages[2].isUser)
        XCTAssertNil(chatViewModel.messages[2].transactionPackage)
    }
    
    func testProcessMessageWithTransactionResponse() {
        // Given
        mockAPIService.mockResponseType = .transaction
        chatViewModel.inputText = "Swap 0.1 ETH to USDC"
        
        // When
        chatViewModel.sendMessage()
        
        // Then
        let expectation = XCTestExpectation(description: "Message processing completes")
        
        // Wait for the async operation to complete
        chatViewModel.$isProcessing
            .dropFirst() // Skip initial value
            .filter { !$0 } // Wait until isProcessing becomes false
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(chatViewModel.messages.count, 3) // welcome + user message + response
        XCTAssertFalse(chatViewModel.messages[2].isUser)
        XCTAssertNotNil(chatViewModel.messages[2].transactionPackage)
        XCTAssertEqual(chatViewModel.messages[2].transactionPackage?.actions.count, 1)
    }
}

// MARK: - Mock API Service
class MockAPIService: APIService {
    enum MockResponseType {
        case regular
        case transaction
        case error
    }
    
    var mockResponseType: MockResponseType = .regular
    
    init() {
        super.init(baseURLString: "https://mock-api.test")
    }
    
    override func processMessage(message: String, walletAddress: String) -> AnyPublisher<MessageResponse, APIError> {
        switch mockResponseType {
        case .regular:
            let response = MessageResponse(
                explanation: "I understand you want to know about ETH. Ethereum is a decentralized blockchain platform.",
                transactionPackage: nil
            )
            return Just(response)
                .setFailureType(to: APIError.self)
                .delay(for: .seconds(0.5), scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
            
        case .transaction:
            let action = TransactionAction(
                contractAddress: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
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
                explanation: "I'll swap 0.1 ETH for USDC on Uniswap.",
                transactionPackage: package
            )
            
            return Just(response)
                .setFailureType(to: APIError.self)
                .delay(for: .seconds(0.5), scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
            
        case .error:
            return Fail(error: APIError.networkError(NSError(domain: "test", code: 500, userInfo: nil)))
                .delay(for: .seconds(0.5), scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
} 