import SwiftUI

struct MainTabView: View {
    @StateObject private var walletViewModel: WalletViewModel
    @StateObject private var chatViewModel: ChatViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init() {
        // Create services
        let rpcService = RPCService(rpcURLString: "https://mainnet.infura.io/v3/YOUR_INFURA_KEY")
        let apiService = APIService(baseURLString: "https://your-grypt-backend.com")
        
        // Initialize view models with a temporary AuthViewModel that will be replaced by the environment object
        let wallet = WalletViewModel(rpcService: rpcService)
        let chat = ChatViewModel(apiService: apiService, authViewModel: AuthViewModel())
        
        // Use _StateObject to properly initialize the StateObjects
        _walletViewModel = StateObject(wrappedValue: wallet)
        _chatViewModel = StateObject(wrappedValue: chat)
    }
    
    var body: some View {
        // Update the chatViewModel's authViewModel reference to use the shared one
        TabView {
            ChatView()
                .environmentObject(chatViewModel)
                .environmentObject(authViewModel)
                .onAppear {
                    // This ensures the chatViewModel uses the shared authViewModel
                    chatViewModel.updateAuthViewModel(authViewModel)
                }
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
            
            HoldingsView()
                .environmentObject(walletViewModel)
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Holdings", systemImage: "wallet.pass.fill")
                }
        }
        .onAppear {
            if let address = authViewModel.walletAddress {
                // When the view appears, load the wallet data
                walletViewModel.refreshWalletData(address: address)
            }
        }
    }
} 