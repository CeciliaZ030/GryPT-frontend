import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct HoldingsView: View {
    @EnvironmentObject var walletViewModel: WalletViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Total balance section
                VStack(spacing: 8) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("$\(calculateTotalValueInUSD(), specifier: "%.2f")")
                        .font(.system(size: 36, weight: .bold))
                    
                    if walletViewModel.isLoading {
                        ProgressView()
                            .padding(.top, 8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()
                
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Assets").tag(0)
                    Text("Activity").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content based on selected tab
                if selectedTab == 0 {
                    assetsList
                } else {
                    activityList
                }
                
                Spacer()
            }
            .navigationTitle("Holdings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        if let address = authViewModel.walletAddress {
                            walletViewModel.refreshWalletData(address: address)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16))
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(walletViewModel.isLoading)
                }
            }
            .onAppear {
                if let address = authViewModel.walletAddress {
                    walletViewModel.loadTransactionHistory(address: address)
                }
            }
        }
    }
    
    private var assetsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(walletViewModel.assets) { asset in
                    AssetRow(asset: asset)
                }
                
                if walletViewModel.assets.isEmpty && !walletViewModel.isLoading {
                    Text("No assets found")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var activityList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(walletViewModel.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
                
                if walletViewModel.transactions.isEmpty {
                    Text("No transactions found")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func calculateTotalValueInUSD() -> Double {
        // This is a simplified calculation
        // In a real app, you would use current exchange rates for all tokens
        let ethUsdPrice = 3500.0 // Example ETH price in USD
        
        // Calculate ETH value
        let ethValue = walletViewModel.ethBalance * ethUsdPrice
        
        // For other tokens, we'd need to fetch their prices
        // For this example, we'll use fixed prices
        let tokenValues = walletViewModel.assets.filter { $0.symbol != "ETH" }.reduce(0.0) { total, asset in
            let price: Double
            switch asset.symbol {
            case "USDC": price = 1.0
            case "USDT": price = 1.0
            case "DAI": price = 1.0
            default: price = 0.0
            }
            
            let divisor = pow(10.0, Double(asset.decimals))
            return total + (asset.balance / divisor) * price
        }
        
        return ethValue + tokenValues
    }
}

struct AssetRow: View {
    let asset: Asset
    
    var body: some View {
        HStack(spacing: 14) {
            // Asset icon
            if let logoURL = asset.logoURL {
                AsyncImage(url: logoURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                    .clipShape(Circle())
            }
            
            // Asset details
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.headline)
                Text(asset.symbol)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Balance
            VStack(alignment: .trailing, spacing: 4) {
                Text(asset.formattedBalance)
                    .font(.headline)
                
                // Calculate USD value based on the asset
                // This is a placeholder implementation
                let usdValue = calculateUsdValue(asset)
                
                Text("$\(usdValue, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func calculateUsdValue(_ asset: Asset) -> Double {
        // Calculate USD value based on the asset symbol
        let divisor = pow(10.0, Double(asset.decimals))
        let value = asset.balance / divisor
        
        switch asset.symbol {
        case "ETH": 
            return value * 3500.0
        case "USDC", "USDT", "DAI": 
            return value
        default: 
            return 0.0
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 14) {
            // Transaction icon
            Image(systemName: isIncoming ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(isIncoming ? .green : .blue)
            
            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                Text(transactionTitle)
                    .font(.headline)
                
                Text(transaction.timestamp, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Value
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.value + " ETH")
                    .font(.headline)
                    .foregroundColor(isIncoming ? .green : .primary)
                
                HStack {
                    Text(transaction.status.rawValue.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var isIncoming: Bool {
        guard let walletAddress = UserDefaults.standard.string(forKey: "walletAddress") else {
            return false
        }
        
        return transaction.to.lowercased() == walletAddress.lowercased()
    }
    
    private var transactionTitle: String {
        if let explanation = transaction.explanation {
            return explanation
        }
        
        return isIncoming ? "Received ETH" : "Sent ETH"
    }
    
    private var statusColor: Color {
        switch transaction.status {
        case .completed: return .green
        case .pending: return .orange
        case .failed: return .red
        }
    }
} 