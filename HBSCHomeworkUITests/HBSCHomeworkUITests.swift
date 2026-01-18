import XCTest

class HBSCHomeworkUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        super.setUp()
        
        // 重置应用状态
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDown()
    }
    
    func testHomePageElements() {
        // 测试首页元素是否正确显示
        
        // 等待应用启动
        let navigationBar = app.navigationBars["首页"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5), "Navigation bar should exist")
        
        // 检查导航栏按钮
        let searchButton = navigationBar.buttons["Search"]
        XCTAssertTrue(searchButton.exists, "Search button should exist")
        
        let profileButton = navigationBar.buttons["person.circle"]
        XCTAssertTrue(profileButton.exists, "Profile button should exist")
        
        // 检查加载指示器
        let activityIndicators = app.activityIndicators
        XCTAssertTrue(activityIndicators.count > 0, "Loading indicator should be shown on first load")
    }
    
    func testNavigationToSearchPage() {
        // 测试导航到搜索页面
        
        // 等待首页加载
        let navigationBar = app.navigationBars["首页"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        
        // 点击搜索按钮
        let searchButton = navigationBar.buttons["Search"]
        searchButton.tap()
        
        // 检查是否导航到搜索页面
        let searchNavigationBar = app.navigationBars["搜索"]
        XCTAssertTrue(searchNavigationBar.waitForExistence(timeout: 5), "Should navigate to search page")
        
        // 检查搜索栏
        let searchField = app.searchFields.element
        XCTAssertTrue(searchField.exists, "Search field should exist")
        
        // 返回首页
        let backButton = searchNavigationBar.buttons["返回"]
        XCTAssertTrue(backButton.exists, "Back button should exist")
        backButton.tap()
        
        // 验证返回首页
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5), "Should navigate back to home page")
    }
    
    func testNavigationToLoginPage() {
        // 测试导航到登录页面
        
        // 等待首页加载
        let navigationBar = app.navigationBars["首页"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        
        // 点击个人资料按钮
        let profileButton = navigationBar.buttons["person.circle"]
        profileButton.tap()
        
        // 检查是否导航到登录页面
        let loginNavigationBar = app.navigationBars["登录"]
        XCTAssertTrue(loginNavigationBar.waitForExistence(timeout: 5), "Should navigate to login page")
        
        // 检查登录页面元素
        let usernameField = app.textFields["login.username"]
        XCTAssertTrue(usernameField.exists, "Username field should exist")
        
        let passwordField = app.secureTextFields["login.password"]
        XCTAssertTrue(passwordField.exists, "Password field should exist")
        
        let loginButton = app.buttons["login.loginButton"]
        XCTAssertTrue(loginButton.exists, "Login button should exist")
        
        // 返回首页
        let backButton = loginNavigationBar.buttons["返回"]
        XCTAssertTrue(backButton.exists, "Back button should exist")
        backButton.tap()
        
        // 验证返回首页
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5), "Should navigate back to home page")
    }
    
    func testLoginFormInteractions() {
        // 测试登录表单交互
        
        // 先导航到登录页面
        let navigationBar = app.navigationBars["首页"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        
        let profileButton = navigationBar.buttons["person.circle"]
        profileButton.tap()
        
        let loginNavigationBar = app.navigationBars["登录"]
        XCTAssertTrue(loginNavigationBar.waitForExistence(timeout: 5))
        
        // 测试输入用户名
        let usernameField = app.textFields["login.username"]
        usernameField.tap()
        usernameField.typeText("testuser")
        XCTAssertEqual(usernameField.value as? String, "testuser", "Username should be entered correctly")
        
        // 测试输入密码
        let passwordField = app.secureTextFields["login.password"]
        passwordField.tap()
        passwordField.typeText("testpassword")
        XCTAssertEqual(passwordField.value as? String, "••••••••••", "Password should be entered correctly")
        
        // 测试清除文本
        usernameField.tap()
        app.keys["Clear text"].tap()
        XCTAssertEqual(usernameField.value as? String, "", "Username should be cleared")
    }
    
    func testLoadingStateDisplay() {
        // 测试加载状态显示
        
        // 等待应用启动
        XCTAssertTrue(app.navigationBars["首页"].waitForExistence(timeout: 5))
        
        // 检查初始加载状态
        let activityIndicators = app.activityIndicators
        XCTAssertTrue(activityIndicators.count > 0, "Loading indicator should be shown initially")
        
        // 等待数据加载完成
        expectation(for: NSPredicate(format: "count == 0"), evaluatedWith: activityIndicators, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        // 验证加载完成后显示tableView
        let tableView = app.tables.element
        XCTAssertTrue(tableView.exists, "TableView should be shown after loading")
    }
}
