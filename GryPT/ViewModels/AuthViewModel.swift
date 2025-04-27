import Foundation
import LocalAuthentication
import CryptoKit
import AuthenticationServices

@available(macOS 12, *)
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let keychainService = "com.grypt.privatekey"
    private let keychainAccount = "wallet"
    
    var walletAddress: String? {
        guard let privateKey = getPrivateKeyFromKeychain() else { return nil }
        // In a real app, derive the wallet address from the private key
        // This is a placeholder implementation
        
        // Convert the first few bytes to hex string
        let prefix = privateKey.prefix(5)
        let hexString = prefix.map { String(format: "%02x", $0) }.joined()
        return "0x" + hexString
    }
    
    init() {
        checkExistingWallet()
    }
    
    private func checkExistingWallet() {
        if getPrivateKeyFromKeychain() != nil {
            authenticateWithBiometrics()
        }
    }
    
    func signInWithApple() {
        isLoading = true
        // In a real app, integrate with ASAuthorizationController for Apple sign-in
        // This is a placeholder implementation that generates a new keypair
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.generateNewWallet()
            self.isLoading = false
            self.isAuthenticated = true
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        // In a real app, integrate with Google Sign-In SDK
        // This is a placeholder implementation that generates a new keypair
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.generateNewWallet()
            self.isLoading = false
            self.isAuthenticated = true
        }
    }
    
    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your crypto wallet"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        self.error = authError?.localizedDescription ?? "Authentication failed"
                    }
                }
            }
        } else {
            self.error = error?.localizedDescription ?? "Face ID not available"
        }
    }
    
    func signOut() {
        isAuthenticated = false
    }
    
    private func generateNewWallet() {
        // In a real app, generate a proper secp256k1 keypair for Ethereum
        // This is a placeholder implementation
        let privateKey = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        savePrivateKeyToKeychain(privateKey)
    }
    
    private func getPrivateKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        
        return data
    }
    
    private func savePrivateKeyToKeychain(_ privateKey: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: privateKey,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Try to add the item
        var status = SecItemAdd(query as CFDictionary, nil)
        
        // If the item already exists, update it
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: keychainAccount
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: privateKey
            ]
            
            status = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
        }
    }
} 
