//
//  JAKeychainManager.swift
//  Job Assistant
//
//  Created by Maruf Memon on 18/01/24.
//

import Foundation

let kKeychain = JAKeychainManager.shared

class JAKeychainManager {
    let coreDataKeyTag = "com.ssms.jobAssistant.coredatadb"
    let serviceIdentifier = "com.ssms.jobAssistant"
    
    static let shared: JAKeychainManager = {
        let instance = JAKeychainManager()
        // setup code
        return instance
    }()
    
    func setup() {
        
    }
    
    func coreDataDBKey() -> String? {
        if let existingKey = keyFromKeychain(for: coreDataKeyTag) {
            print("Existing key found: \(existingKey)")
            return existingKey
        } else {
            if let newKey = generateAndStoreKeyInKeychain() {
                print("New key created and stored: \(newKey)")
                return newKey
            } else {
                print("Failed to create and store a new key")
                return nil
            }
        }
    }
    
    func keyFromKeychain(for tag: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: coreDataKeyTag,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let keyData = item as? Data else {
            print("Error fetching encryption key from Keychain. Status: \(status)")
            return nil
        }
        
        return String(data: keyData, encoding: .utf8)
    }
    
    private func generateAndStoreKeyInKeychain() -> String? {
        let newKey = UUID().uuidString // 256-bit key for example
        if let data = newKey.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: serviceIdentifier,
                kSecAttrAccount as String: coreDataKeyTag,
                kSecValueData as String: data
            ]
            
            SecItemDelete(query as CFDictionary)
            
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                print("Error saving encryption key to Keychain. Status: \(status)")
                return nil
            }
            print("Encryption key saved to Keychain.")
            return newKey
        }
        print("Data is nil while saving key to keychain item")
        return nil
    }
    
    func save(password: String, for key: String, in account: String) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password.data(using: .utf8)! as AnyObject
        ]
        
        // Add a the new item to the keychain.
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw NSError() }
    }
    
    func read(for key: String, in account: String) throws -> String {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnData as String: kCFBooleanTrue
        ]
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw NSError() }
        guard status == noErr else { throw NSError() }
        
        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw NSError()
        }
        
        return password
    }
}
