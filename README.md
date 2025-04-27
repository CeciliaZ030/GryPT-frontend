# GryPT Frontend

GryPT is an AI-driven crypto wallet app that allows users to execute crypto transactions using natural language commands. This SwiftUI app provides a chat interface for interacting with the AI assistant and a wallet interface for viewing balances and transaction history.

## Features

- **Natural Language Commands**: Send crypto instructions using plain English (e.g., "Swap 0.1 ETH to USDC on Uniswap")
- **Secure Authentication**: Authenticate with Apple ID or Google, with Face ID for transaction approval
- **Crypto Wallet**: View your ETH and ERC-20 token balances
- **Transaction History**: Track your on-chain activity
- **AI Assistant**: Chat with an AI that understands crypto commands and explains each step

## Project Structure

The app follows standard SwiftUI architecture patterns:

- **Models/**: Data structures for assets, transactions, etc.
- **ViewModels/**: State management and business logic
- **Views/**: SwiftUI UI components
- **Services/**: API and RPC services for backend communication

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- An active internet connection
- Infura API key (for Ethereum RPC)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/GryPT-frontend.git
   cd GryPT-frontend
   ```

2. Open the project in Xcode:
   ```bash
   open GryPT.xcodeproj
   ```

3. Configure API keys:
   - In `MainTabView.swift`, replace `YOUR_INFURA_KEY` with your actual Infura API key
   - Set the backend URL in `APIService` initialization

4. Build and run the app in the iOS Simulator or on a physical device.

## Usage

### Authentication

1. Launch the app
2. If you don't have a wallet, you'll be presented with the authentication screen
3. Choose either "Continue with Apple" or "Continue with Google"
4. After successful authentication, a new Ethereum wallet will be created for you
5. For subsequent app launches, you'll authenticate with Face ID

### Chat Interface

1. Navigate to the "Chat" tab
2. Type a natural language command (e.g., "Swap 0.1 ETH to USDC on Uniswap")
3. The AI will process your request and provide a detailed transaction plan
4. Review the transaction details
5. Approve with Face ID to execute the transaction

### Holdings View

1. Navigate to the "Holdings" tab
2. View your ETH and token balances
3. Switch to the "Activity" tab to see your transaction history

## Security Considerations

- Private keys are stored securely in the Apple Keychain
- Face ID is required for every transaction
- All transaction signing happens locally on the device
- No private keys are ever transmitted over the network

## Backend Integration

This frontend app communicates with the GryPT backend server for:
- Processing natural language commands
- Fetching smart contract ABIs
- Generating transaction packages

For backend setup instructions, refer to the [GryPT Backend Repository](https://github.com/yourusername/GryPT-backend).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## App Structure
- Two main flows: **Authentication** and **Main App**.
- Main App has two tabs: **Chat** and **Holdings**.

---

## Authentication Flow
- **On app launch**:
  - Check if private key exists in **Apple Keychain**.
- **If no key**:
  - Show `AuthFlowView` with options:
    - "Continue with Apple" button
    - "Continue with Google" button
- **Sign Up**:
  - Authenticate user with Apple or Google.
  - After success:
    - Generate an **Ethereum keypair** (secp256k1).
    - Store the private key securely in **Keychain**.
- **Sign In**:
  - If private key exists:
    - Prompt Face ID (using `LocalAuthentication`).
    - On success, unlock wallet and enter app.
- **Authentication state**:
  - Managed by a shared `AuthViewModel`.

---

## Main App Flow
- After successful authentication:
  - Show a `TabView` with two tabs:
    1. `ChatView`
       - Natural language input for crypto commands.
    2. `HoldingsView`
       - Displays wallet balances and transaction history.

---

## Holdings Page (Wallet)

### Requirements:
- Connect to a **provided Ethereum RPC endpoint** (passed in config).
- Query **ETH balance** for the logged-in wallet address.
- Query **ERC-20 token balances** for the same address.
- Display list of:
  - Token symbol (e.g., ETH, USDC)
  - Token name (e.g., Ethereum, USD Coin)
  - Balance (formatted in human-readable units)
- Display token logos if available (optional, placeholder if not).

---

### Technical Details:
- Use **eth_getBalance** RPC method to fetch ETH balance.
- For ERC-20 tokens:
  - Use `balanceOf(address)` function call via JSON-RPC `eth_call`.
  - Need each token's contract address and decimals.
  - Load a predefined list of common token contracts.
- Use the provided **chain RPC endpoint** for all on-chain reads.
- Show loading indicator while fetching balances.
- Handle errors gracefully (e.g., unable to connect to RPC).

---

### Wallet Data Structures
```swift
struct Asset {
    let name: String
    let symbol: String
    let balance: Double
    let logoURL: URL?
}
```

```swift
struct WalletState {
    var ethBalance: Double
    var assets: [Asset]
}
```

---

### HoldingsView Behavior
- OnAppear:
  - Connect to RPC endpoint.
  - Fetch ETH balance.
  - Fetch each ERC-20 token balance.
  - Update the list with results.
- Show a **refresh button** to manually reload balances.

---

## Key Managers / Helpers
- `RPCService`
  - Manages connection to chain RPC.
  - Fetches ETH and ERC-20 balances.
- `WalletViewModel`
  - Holds current balance state.
  - Manages fetching assets from blockchain.

---

## Flow Summary

```plaintext
App Launch
↓
Check Keychain for Wallet
↓
If no Wallet → AuthFlowView (Sign Up)
↓
If Wallet → Face ID Authentication (Sign In)
↓
On Success → MainTabView (Chat + Holdings)
↓
HoldingsView → Fetch ETH + token balances from provided RPC endpoint
↓
Display list of assets
```
