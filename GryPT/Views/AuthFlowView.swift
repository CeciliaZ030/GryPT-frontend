import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "wallet.pass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("GryPT")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.primary)
            
            Text("AI-Powered Crypto Wallet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    authViewModel.signInWithApple()
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.headline)
                        Text("Continue with Apple")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    authViewModel.signInWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.headline)
                        Text("Continue with Google")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 32)
            
            if authViewModel.isLoading {
                ProgressView()
                    .padding()
            }
            
            if let error = authViewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
                .frame(height: 50)
        }
        .padding()
    }
} 