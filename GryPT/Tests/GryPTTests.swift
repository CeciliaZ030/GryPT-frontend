import XCTest
@testable import GryPT

class GryPTTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAllViewModels() {
        // This is a container test that can be used to run all the tests
        // from a single execution point if needed
        
        // Run AuthViewModel tests
        let authTests = AuthViewModelTests()
        authTests.setUp()
        authTests.testInitialState()
        authTests.testSignInWithApple()
        authTests.testSignInWithGoogle()
        authTests.testSignOut()
        authTests.tearDown()
        
        // Run ChatViewModel tests
        let chatTests = ChatViewModelTests()
        chatTests.setUp()
        chatTests.testInitialState()
        chatTests.testSendMessage()
        chatTests.testSendEmptyMessage()
        chatTests.testUpdateAuthViewModel()
        chatTests.testProcessMessageWithoutWallet()
        chatTests.testProcessMessageWithRegularResponse()
        chatTests.testProcessMessageWithTransactionResponse()
        chatTests.tearDown()
        
        // Run WalletViewModel tests
        let walletTests = WalletViewModelTests()
        walletTests.setUp()
        walletTests.testInitialState()
        walletTests.testLoadWalletData()
        walletTests.testLoadTransactionHistory()
        walletTests.testRefreshWalletData()
        walletTests.testCalculateTotalValueInUSD()
        walletTests.tearDown()
    }
    
    func testUITestingMode() {
        // This enables the app to detect when it's running in UI test mode
        // by checking for this launch argument
        if ProcessInfo.processInfo.arguments.contains("UITesting") {
            // Set up mock data for UI testing
            // This would set up necessary states for the UI tests
            print("Running in UI testing mode")
        }
    }
} 