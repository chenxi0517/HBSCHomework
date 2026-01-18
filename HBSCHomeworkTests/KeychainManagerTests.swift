import XCTest
@testable import HBSCHomework

class KeychainManagerTests: XCTestCase {
    
    var keychainManager: KeychainManager!
    
    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager.shared
        // 清除所有现有数据，确保测试环境干净
        keychainManager.clearAll()
    }
    
    override func tearDown() {
        // 测试完成后清除数据
        keychainManager.clearAll()
        keychainManager = nil
        super.tearDown()
    }
    
    func testSaveAndLoadString() {
        // 测试保存和加载字符串
        let testKey = "testKey"
        let testValue = "testValue"
        
        // 保存字符串
        let saveSuccess = keychainManager.save(string: testValue, forKey: testKey)
        XCTAssertTrue(saveSuccess, "Failed to save string to Keychain")
        
        // 加载字符串
        let loadedValue = keychainManager.loadString(forKey: testKey)
        XCTAssertEqual(loadedValue, testValue, "Loaded string doesn't match saved string")
    }
    
    func testSaveAndLoadCredentials() {
        // 测试保存和加载用户凭据
        let testUsername = "testUser"
        let testPassword = "testPassword123"
        
        // 保存凭据
        let saveSuccess = keychainManager.saveCredentials(username: testUsername, password: testPassword)
        XCTAssertTrue(saveSuccess, "Failed to save credentials to Keychain")
        
        // 加载凭据
        let (loadedUsername, loadedPassword) = keychainManager.loadCredentials()
        XCTAssertEqual(loadedUsername, testUsername, "Loaded username doesn't match saved username")
        XCTAssertEqual(loadedPassword, testPassword, "Loaded password doesn't match saved password")
    }
    
    func testDeleteData() {
        // 测试删除数据
        let testKey = "testKey"
        let testValue = "testValue"
        
        // 先保存数据
        keychainManager.save(string: testValue, forKey: testKey)
        
        // 删除数据
        let deleteSuccess = keychainManager.deleteData(forKey: testKey)
        XCTAssertTrue(deleteSuccess, "Failed to delete data from Keychain")
        
        // 验证数据已被删除
        let loadedValue = keychainManager.loadString(forKey: testKey)
        XCTAssertNil(loadedValue, "Data should be nil after deletion")
    }
    
    func testClearAll() {
        // 测试清除所有数据
        // 先保存一些数据
        keychainManager.save(string: "value1", forKey: "key1")
        keychainManager.save(string: "value2", forKey: "key2")
        keychainManager.saveCredentials(username: "user", password: "pass")
        
        // 清除所有数据
        let clearSuccess = keychainManager.clearAll()
        XCTAssertTrue(clearSuccess, "Failed to clear all data from Keychain")
        
        // 验证所有数据已被清除
        XCTAssertNil(keychainManager.loadString(forKey: "key1"), "key1 should be nil after clearAll")
        XCTAssertNil(keychainManager.loadString(forKey: "key2"), "key2 should be nil after clearAll")
        let (username, password) = keychainManager.loadCredentials()
        XCTAssertNil(username, "Username should be nil after clearAll")
        XCTAssertNil(password, "Password should be nil after clearAll")
    }
}
