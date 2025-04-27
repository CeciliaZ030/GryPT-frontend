import XCTest

class GryPTUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UITesting"]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testLaunchAndSplashScreen() {
        // Verify that the splash screen appears
        XCTAssertTrue(app.staticTexts["GryPT"].exists)
        XCTAssertTrue(app.staticTexts["AI-Powered Crypto Wallet"].exists)
        
        // Wait for the splash screen to disappear (2 seconds + animation)
        let authFlowExpectation = expectation(description: "Splash screen disappears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            authFlowExpectation.fulfill()
        }
        wait(for: [authFlowExpectation], timeout: 4)
        
        // Verify auth flow appears
        XCTAssertTrue(app.buttons["Continue with Apple"].exists)
        XCTAssertTrue(app.buttons["Continue with Google"].exists)
    }
    
    func testAuthFlow() {
        // Wait for splash screen to disappear
        let splashExpectation = expectation(description: "Splash screen disappears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            splashExpectation.fulfill()
        }
        wait(for: [splashExpectation], timeout: 4)
        
        // Tap the "Continue with Apple" button
        app.buttons["Continue with Apple"].tap()
        
        // Wait for the main app to appear
        let mainAppExpectation = expectation(description: "Main app appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            mainAppExpectation.fulfill()
        }
        wait(for: [mainAppExpectation], timeout: 3)
        
        // Verify that the tab bar appears
        XCTAssertTrue(app.tabBars.buttons["Chat"].exists)
        XCTAssertTrue(app.tabBars.buttons["Holdings"].exists)
        
        // Verify that the chat screen is visible by default
        XCTAssertTrue(app.navigationBars["Chat"].exists)
    }
    
    func testTabNavigation() {
        // Wait for splash and auth flow
        loginToApp()
        
        // Verify initial state (Chat tab)
        XCTAssertTrue(app.navigationBars["Chat"].exists)
        
        // Tap on Holdings tab
        app.tabBars.buttons["Holdings"].tap()
        
        // Verify Holdings screen appears
        XCTAssertTrue(app.navigationBars["Holdings"].exists)
        XCTAssertTrue(app.staticTexts["Total Balance"].exists)
        
        // Tap back to Chat tab
        app.tabBars.buttons["Chat"].tap()
        
        // Verify Chat screen appears again
        XCTAssertTrue(app.navigationBars["Chat"].exists)
    }
    
    func testChatInteraction() {
        // Wait for splash and auth flow
        loginToApp()
        
        // Verify chat screen elements
        XCTAssertTrue(app.textFields["Type a message..."].exists)
        XCTAssertTrue(app.buttons["person.crop.circle"].exists)
        
        // Type a message
        let textField = app.textFields["Type a message..."]
        textField.tap()
        textField.typeText("Tell me about ETH")
        
        // Send the message
        app.buttons["arrow.up.circle.fill"].tap()
        
        // Wait for response
        let responseExpectation = expectation(description: "Response appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            responseExpectation.fulfill()
        }
        wait(for: [responseExpectation], timeout: 3)
        
        // Verify response (this is a basic check, may need adjustment based on your UI)
        XCTAssertTrue(app.staticTexts.count > 1)
    }
    
    func testProfileFlow() {
        // Wait for splash and auth flow
        loginToApp()
        
        // Tap profile button
        app.buttons["person.crop.circle"].tap()
        
        // Verify profile screen appears
        let profileExpectation = expectation(description: "Profile appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            profileExpectation.fulfill()
        }
        wait(for: [profileExpectation], timeout: 2)
        
        XCTAssertTrue(app.staticTexts["Your Wallet"].exists)
        XCTAssertTrue(app.buttons["Sign Out"].exists)
        
        // Close profile
        app.buttons["Close"].tap()
        
        // Verify chat screen reappears
        XCTAssertTrue(app.navigationBars["Chat"].exists)
    }
    
    // MARK: - Helper Methods
    
    private func loginToApp() {
        // Wait for splash screen to disappear
        let splashExpectation = expectation(description: "Splash screen disappears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            splashExpectation.fulfill()
        }
        wait(for: [splashExpectation], timeout: 4)
        
        // Tap the "Continue with Apple" button
        app.buttons["Continue with Apple"].tap()
        
        // Wait for the main app to appear
        let mainAppExpectation = expectation(description: "Main app appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            mainAppExpectation.fulfill()
        }
        wait(for: [mainAppExpectation], timeout: 3)
    }
} 