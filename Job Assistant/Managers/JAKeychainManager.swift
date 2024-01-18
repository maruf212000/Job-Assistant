//
//  JAKeychainManager.swift
//  Job Assistant
//
//  Created by Maruf Memon on 18/01/24.
//

import Foundation

let kKeychain = JAKeychainManager.shared

let coreDataKeyTag = "com.ssms.jobAssistant.coredatadb"

class JAKeychainManager {
    
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
        let query = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecReturnData as String: true
        ] as [String: Any]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let keyData = result as? String {
            return keyData
        } else {
            return nil
        }
    }
    
    private func generateAndStoreKeyInKeychain() -> String? {
        let newKey = UUID().uuidString // 256-bit key for example
        
        let query = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: coreDataKeyTag,
            kSecValueData as String: newKey
        ] as [String: Any]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return newKey
        } else {
            return nil
        }
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
