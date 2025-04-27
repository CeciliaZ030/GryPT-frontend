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
  - Need each token’s contract address and decimals.
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
