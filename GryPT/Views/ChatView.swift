import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Chat messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatViewModel.messages) { message in
                            MessageView(message: message)
                                .environmentObject(chatViewModel)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                // Input field
                HStack {
                    TextField("Type a message...", text: $chatViewModel.inputText)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                        .disabled(chatViewModel.isProcessing)
                    
                    Button(action: {
                        chatViewModel.sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(chatViewModel.inputText.isEmpty || chatViewModel.isProcessing ? .gray : .blue)
                    }
                    .disabled(chatViewModel.inputText.isEmpty || chatViewModel.isProcessing)
                }
                .padding()
            }
            .navigationTitle("Chat")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(authViewModel)
            }
            .overlay(
                Group {
                    if chatViewModel.isProcessing {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
            )
        }
    }
}

struct MessageView: View {
    let message: ChatMessage
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showTransactionDetails = false
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
            HStack {
                if !message.isUser {
                    Image(systemName: "wallet.pass.fill")
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Text(message.content)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color.gray.opacity(0.1))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(18)
                
                if message.isUser {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            if let package = message.transactionPackage {
                Button(action: {
                    showTransactionDetails = true
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Review Transaction")
                        Spacer()
                        Text("Total: \(package.totalValue)")
                            .fontWeight(.semibold)
                    }
                    .padding(12)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green, lineWidth: 1)
                    )
                }
                .padding(.top, 4)
                .sheet(isPresented: $showTransactionDetails) {
                    TransactionDetailView(package: package)
                        .environmentObject(chatViewModel)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
        .padding(.vertical, 4)
    }
}

struct TransactionDetailView: View {
    let package: TransactionPackage
    @EnvironmentObject var chatViewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Transaction overview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Transaction Overview")
                            .font(.headline)
                        
                        HStack {
                            Text("Total Value:")
                            Spacer()
                            Text(package.totalValue)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Estimated Gas:")
                            Spacer()
                            Text(package.totalGasEstimate)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Transaction steps
                    ForEach(Array(package.actions.enumerated()), id: \.element.id) { index, action in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Step \(index + 1)")
                                .font(.headline)
                            
                            if let contractAddress = action.contractAddress {
                                HStack {
                                    Text("Contract:")
                                    Spacer()
                                    Text(contractAddress.prefix(6) + "..." + contractAddress.suffix(4))
                                        .fontWeight(.medium)
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                            
                            if let functionName = action.functionName {
                                HStack {
                                    Text("Function:")
                                    Spacer()
                                    Text(functionName)
                                        .fontWeight(.medium)
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                            
                            if action.value != "0" {
                                HStack {
                                    Text("Value:")
                                    Spacer()
                                    Text(action.value)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            Divider()
                            
                            Text("Explanation:")
                                .fontWeight(.medium)
                            Text(action.explanation)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Transaction Details")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    chatViewModel.approveTransaction(package)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Approve with Face ID")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
                .background(Color.white)
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding()
                
                Text("Your Wallet")
                    .font(.headline)
                
                if let address = authViewModel.walletAddress {
                    Text(address)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    authViewModel.signOut()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square.fill")
                        Text("Sign Out")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
} 