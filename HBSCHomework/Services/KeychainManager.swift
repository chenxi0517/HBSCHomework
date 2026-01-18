import Foundation
import Security

class KeychainManager {
    
    // MARK: - Singleton
    
    static let shared = KeychainManager()
    private init() {}
    
    // MARK: - Constants
    
    private let serviceName = Bundle.main.bundleIdentifier ?? "com.hbschomework"
    
    // MARK: - Keychain Operations
    
    /// 存储数据到Keychain
    func save(data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // 先删除已存在的数据
        SecItemDelete(query as CFDictionary)
        
        // 添加新数据
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// 从Keychain读取数据
    func loadData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }
    
    /// 从Keychain删除数据
    func deleteData(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    /// 清除所有Keychain数据
    func clearAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Convenience Methods
    
    /// 存储字符串到Keychain
    func save(string: String, forKey key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data: data, forKey: key)
    }
    
    /// 从Keychain读取字符串
    func loadString(forKey key: String) -> String? {
        guard let data = loadData(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// 存储用户名和密码到Keychain
    func saveCredentials(username: String, password: String) -> Bool {
        let success1 = save(string: username, forKey: "kUsernameKey")
        let success2 = save(string: password, forKey: "kPasswordKey")
        return success1 && success2
    }
    
    /// 从Keychain读取用户名和密码
    func loadCredentials() -> (username: String?, password: String?) {
        let username = loadString(forKey: "kUsernameKey")
        let password = loadString(forKey: "kPasswordKey")
        return (username, password)
    }
    
    /// 删除Keychain中的用户名和密码
    func deleteCredentials() -> Bool {
        let success1 = deleteData(forKey: "kUsernameKey")
        let success2 = deleteData(forKey: "kPasswordKey")
        return success1 && success2
    }
}