import XCTest
import Combine
@testable import GryPT

class AuthViewModelTests: XCTestCase {
    var authViewModel: AuthViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        authViewModel = AuthViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        authViewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(authViewModel.isAuthenticated)
        XCTAssertFalse(authViewModel.isLoading)
        XCTAssertNil(authViewModel.error)
    }
    
    func testSignInWithApple() {
        // Given
        let expectation = XCTestExpectation(description: "Apple sign-in completes")
        
        // When
        authViewModel.signInWithApple()
        
        // Then
        XCTAssertTrue(authViewModel.isLoading)
        
        // Wait for the async operation to complete
        authViewModel.$isLoading
            .dropFirst() // Skip the initial value
            .filter { !$0 } // Wait until isLoading becomes false
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(authViewModel.isAuthenticated)
        XCTAssertFalse(authViewModel.isLoading)
        XCTAssertNotNil(authViewModel.walletAddress)
    }
    
    func testSignInWithGoogle() {
        // Given
        let expectation = XCTestExpectation(description: "Google sign-in completes")
        
        // When
        authViewModel.signInWithGoogle()
        
        // Then
        XCTAssertTrue(authViewModel.isLoading)
        
        // Wait for the async operation to complete
        authViewModel.$isLoading
            .dropFirst() // Skip the initial value
            .filter { !$0 } // Wait until isLoading becomes false
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(authViewModel.isAuthenticated)
        XCTAssertFalse(authViewModel.isLoading)
        XCTAssertNotNil(authViewModel.walletAddress)
    }
    
    func testSignOut() {
        // Given
        authViewModel.signInWithApple()
        let expectation = XCTestExpectation(description: "Sign-in completes")
        
        // Wait for sign-in to complete
        authViewModel.$isLoading
            .dropFirst()
            .filter { !$0 }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(authViewModel.isAuthenticated)
        
        // When
        authViewModel.signOut()
        
        // Then
        XCTAssertFalse(authViewModel.isAuthenticated)
    }
    
    // Note: Testing biometric authentication requires the LAContext to be mocked
    // which is beyond the scope of this basic test suite
} 