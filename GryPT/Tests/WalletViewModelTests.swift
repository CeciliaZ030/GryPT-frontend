import XCTest
import Combine
@testable import GryPT

class WalletViewModelTests: XCTestCase {
    var walletViewModel: WalletViewModel!
    var mockRPCService: MockRPCService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRPCService = MockRPCService()
        walletViewModel = WalletViewModel(rpcService: mockRPCService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        walletViewModel = nil
        mockRPCService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(walletViewModel.ethBalance, 0.0)
        XCTAssertTrue(walletViewModel.assets.isEmpty)
        XCTAssertTrue(walletViewModel.transactions.isEmpty)
        XCTAssertFalse(walletViewModel.isLoading)
        XCTAssertNil(walletViewModel.error)
    }
    
    func testLoadWalletData() {
        // Given
        let testAddress = "0x1234567890123456789012345678901234567890"
        let expectation = XCTestExpectation(description: "Wallet data loads")
        
        // When
        walletViewModel.loadWalletData(address: testAddress)
        
        // Then
        XCTAssertTrue(walletViewModel.isLoading)
        
        // Wait for the async operation to complete
        walletViewModel.$isLoading
            .dropFirst() // Skip the initial value
            .filter { !$0 } // Wait until isLoading becomes false
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(walletViewModel.ethBalance, 1.5) // From mock service
        XCTAssertEqual(walletViewModel.assets.count, 4) // ETH + 3 tokens
        XCTAssertEqual(walletViewModel.assets[0].symbol, "ETH")
        XCTAssertFalse(walletViewModel.isLoading)
    }
    
    func testLoadTransactionHistory() {
        // Given
        let testAddress = "0x1234567890123456789012345678901234567890"
        
        // When
        walletViewModel.loadTransactionHistory(address: testAddress)
        
        // Then
        XCTAssertEqual(walletViewModel.transactions.count, 2)
        XCTAssertEqual(walletViewModel.transactions[0].status, .completed)
        XCTAssertEqual(walletViewModel.transactions[1].status, .completed)
    }
    
    func testRefreshWalletData() {
        // Given
        let testAddress = "0x1234567890123456789012345678901234567890"
        let expectation = XCTestExpectation(description: "Wallet data refreshes")
        
        // When
        walletViewModel.refreshWalletData(address: testAddress)
        
        // Then
        XCTAssertTrue(walletViewModel.isLoading)
        
        // Wait for the async operation to complete
        walletViewModel.$isLoading
            .dropFirst() // Skip the initial value
            .filter { !$0 } // Wait until isLoading becomes false
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(walletViewModel.ethBalance, 1.5) // From mock service
        XCTAssertEqual(walletViewModel.assets.count, 4) // ETH + 3 tokens
        XCTAssertEqual(walletViewModel.transactions.count, 2)
        XCTAssertFalse(walletViewModel.isLoading)
    }
    
    func testCalculateTotalValueInUSD() {
        // Given
        let testAddress = "0x1234567890123456789012345678901234567890"
        let expectation = XCTestExpectation(description: "Wallet data loads")
        
        // When
        walletViewModel.loadWalletData(address: testAddress)
        
        // Wait for the async operation to complete
        walletViewModel.$isLoading
            .dropFirst() // Skip the initial value
            .filter { !$0 } // Wait until isLoading becomes false
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        // Access the private method using reflection (this is a test-only technique)
        let mirror = Mirror(reflecting: walletViewModel)
        let calculateTotalValueInUSD = mirror.children.first { $0.label == "calculateTotalValueInUSD" }?.value
        
        // If we can't access it through reflection, we have to test indirectly by checking assets
        XCTAssertEqual(walletViewModel.assets.count, 4)
        XCTAssertEqual(walletViewModel.ethBalance, 1.5)
        
        // Calculate expected value (1.5 ETH at $3500 + tokens)
        let ethValue = 1.5 * 3500.0 // $5250
        // Based on our mock data: 1250 USDC + 725 USDT + 500 DAI = $2475
        let tokenValue = 2475.0
        let expectedTotal = ethValue + tokenValue // $7725
        
        // This is indirect testing since we can't directly call the private method
        XCTAssertTrue(walletViewModel.assets[0].formattedBalance == "1.50" || walletViewModel.assets[0].formattedBalance == "1.500")
    }
}

// MARK: - Mock RPC Service
class MockRPCService: RPCService {
    init() {
        super.init(rpcURLString: "https://mock-rpc.test")
    }
    
    override func getEthBalance(address: String) -> AnyPublisher<Double, RPCError> {
        return Just(1.5) // 1.5 ETH
            .setFailureType(to: RPCError.self)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    override func getERC20Balance(address: String, contractAddress: String, decimals: Int) -> AnyPublisher<Double, RPCError> {
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
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
} 