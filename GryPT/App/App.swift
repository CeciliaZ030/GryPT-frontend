import SwiftUI

@main
struct GryPTApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isShowingSplash = true
    
    init() {
        // Check if running in UI testing mode
        if ProcessInfo.processInfo.arguments.contains("UITesting") {
            // Skip long animations and timeouts for UI tests
            isShowingSplash = false
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                LaunchScreen()
                    .onAppear {
                        // Show splash screen for 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isShowingSplash = false
                            }
                        }
                    }
            } else if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                AuthFlowView()
                    .environmentObject(authViewModel)
            }
        }
    }
} 