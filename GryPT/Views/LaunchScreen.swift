import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "wallet.pass.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)
            
            Text("GryPT")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
            
            Text("AI-Powered Crypto Wallet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("© 2023 GryPT")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom)
        }
        .padding()
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
} 