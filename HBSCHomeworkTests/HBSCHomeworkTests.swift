import XCTest
@testable import HBSCHomework

class HBSCHomeworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // 重置应用状态
    }
    
    override func tearDown() {
        // 清理测试资源
        super.tearDown()
    }
    
    func testLocalization() {
        // 测试本地化字符串加载
        XCTAssertEqual("home.title".localized, "首页", "Localized string should be correct")
        XCTAssertEqual("login.title".localized, "登录", "Localized string should be correct")
    }
    
    func testRepositoryModel() {
        // 测试Repository模型初始化
        let owner = Repository.Owner(login: "testuser", avatarUrl: "https://github.com/avatar.png")
        let now = Date()
        let repository = Repository(id: 1, 
                                   name: "TestRepo", 
                                   fullName: "user/TestRepo", 
                                   owner: owner,
                                   description: "Test description",
                                   htmlUrl: "https://github.com/user/TestRepo",
                                   stargazersCount: 100,
                                   forksCount: 50,
                                   language: "Swift",
                                   createdAt: now,
                                   updatedAt: now)
        
        XCTAssertEqual(repository.id, 1, "Repository id should be correct")
        XCTAssertEqual(repository.name, "TestRepo", "Repository name should be correct")
        XCTAssertEqual(repository.stargazersCount, 100, "Repository stars count should be correct")
        XCTAssertEqual(repository.owner.login, "testuser", "Repository owner should be correct")
    }
    
    func testUserModel() {
        // 测试User模型初始化
        let user = User(id: 1, 
                       login: "testuser", 
                       avatarUrl: "https://github.com/avatar.png",
                       name: "Test User",
                       bio: "Test bio",
                       publicRepos: 10,
                       followers: 5,
                       following: 3,
                       email: "test@example.com",
                       location: "Test Location")
        
        XCTAssertEqual(user.id, 1, "User id should be correct")
        XCTAssertEqual(user.login, "testuser", "User login should be correct")
        XCTAssertEqual(user.avatarUrl, "https://github.com/avatar.png", "User avatar URL should be correct")
        XCTAssertEqual(user.name, "Test User", "User name should be correct")
        XCTAssertEqual(user.bio, "Test bio", "User bio should be correct")
        XCTAssertEqual(user.publicRepos, 10, "User public repos should be correct")
        XCTAssertEqual(user.followers, 5, "User followers should be correct")
        XCTAssertEqual(user.following, 3, "User following should be correct")
    }
    
    func testHomeViewControllerInitialization() {
        // 测试HomeViewController初始化
        let homeVC = HomeViewController()
        homeVC.loadViewIfNeeded()
        
        XCTAssertNotNil(homeVC.view, "HomeViewController view should be loaded")
        XCTAssertEqual(homeVC.title, "首页", "HomeViewController title should be correct")
    }
    
    func testLoginViewControllerInitialization() {
        // 测试LoginViewController初始化
        let loginVC = LoginViewController()
        loginVC.loadViewIfNeeded()
        
        XCTAssertNotNil(loginVC.view, "LoginViewController view should be loaded")
        XCTAssertEqual(loginVC.title, "登录", "LoginViewController title should be correct")
    }
}
