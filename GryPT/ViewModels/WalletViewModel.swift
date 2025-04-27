import Foundation
import Combine

class WalletViewModel: ObservableObject {
    @Published var ethBalance: Double = 0.0
    @Published var assets: [Asset] = []
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let rpcService: RPCService
    
    init(rpcService: RPCService) {
        self.rpcService = rpcService
    }
    
    func loadWalletData(address: String) {
        isLoading = true
        error = nil
        
        // Load ETH balance
        rpcService.getEthBalance(address: address)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.error = error.localizedDescription
                    }
                },
                receiveValue: { balance in
                    self.ethBalance = balance
                    // Add ETH as an asset
                    self.assets = [
                        Asset(
                            name: "Ethereum",
                            symbol: "ETH",
                            balance: balance,
                            decimals: 18,
                            contractAddress: nil,
                            logoURL: URL(string: "https://ethereum.org/eth-logo.png")
                        )
                    ]
                    
                    // Now load ERC-20 tokens
                    self.loadTokenBalances(address: address)
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadTokenBalances(address: String) {
        // Common ERC-20 tokens to check
        let tokens = [
            (name: "USD Coin", symbol: "USDC", contractAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", decimals: 6),
            (name: "Tether", symbol: "USDT", contractAddress: "0xdAC17F958D2ee523a2206206994597C13D831ec7", decimals: 6),
            (name: "Dai", symbol: "DAI", contractAddress: "0x6B175474E89094C44Da98b954EedeAC495271d0F", decimals: 18)
        ]
        
        let tokenPublishers = tokens.map { token in
            rpcService.getERC20Balance(
                address: address,
                contractAddress: token.contractAddress,
                decimals: token.decimals
            )
            .map { balance -> Asset in
                Asset(
                    name: token.name,
                    symbol: token.symbol,
                    balance: balance,
                    decimals: token.decimals,
                    contractAddress: token.contractAddress,
                    logoURL: URL(string: "https://tokens.1inch.io/\(token.contractAddress).png")
                )
            }
            .catch { error -> AnyPublisher<Asset, Never> in
                // If we can't get the balance, return an asset with 0 balance
                let asset = Asset(
                    name: token.name,
                    symbol: token.symbol,
                    balance: 0,
                    decimals: token.decimals,
                    contractAddress: token.contractAddress,
                    logoURL: URL(string: "https://tokens.1inch.io/\(token.contractAddress).png")
                )
                return Just(asset).eraseToAnyPublisher()
            }
        }
        
        Publishers.MergeMany(tokenPublishers)
            .collect()
            .sink { tokenAssets in
                // Add token assets to our existing ETH asset
                self.assets.append(contentsOf: tokenAssets)
                self.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    func loadTransactionHistory(address: String) {
        // In a real app, fetch transaction history from an API or blockchain
        // This is a placeholder with mock data
        let mockTransactions = [
            Transaction(
                hash: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
                from: address,
                to: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
                value: "0.1",
                timestamp: Date().addingTimeInterval(-86400),
                status: .completed,
                explanation: "Sent 0.1 ETH to vitalik.eth",
                contractAddress: nil,
                functionName: nil,
                functionArgs: nil
            ),
            Transaction(
                hash: "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
                from: "0x3671aE578E63FdF66ad4F3E12CC0c0d71Ac7510C",
                to: address,
                value: "0.5",
                timestamp: Date().addingTimeInterval(-172800),
                status: .completed,
                explanation: "Received 0.5 ETH from Binance",
                contractAddress: nil,
                functionName: nil,
                functionArgs: nil
            )
        ]
        
        self.transactions = mockTransactions
    }
    
    func refreshWalletData(address: String) {
        loadWalletData(address: address)
        loadTransactionHistory(address: address)
    }
} 