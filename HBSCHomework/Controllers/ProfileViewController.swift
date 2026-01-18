import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let avatarImageView = AsyncImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let bioLabel = UILabel()
    private let statsStackView = UIStackView()
    private let logoutButton = UIButton(type: .system)
    private let containerView = UIView()
    
    private var username: String?
    private var isCurrentUser = false
    
    // MARK: - Initialization
    
    init(username: String? = nil) {
        self.username = username
        let (currentUsername, _) = KeychainManager.shared.loadCredentials()
        self.isCurrentUser = (username == nil || username == currentUsername)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserInfo()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = isCurrentUser ? "profile.title".localized : ""
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.greaterThanOrEqualTo(300) // 确保容器高度足够容纳所有子视图
        }
        
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = .systemGray4
        containerView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        loginLabel.font = .systemFont(ofSize: 16)
        loginLabel.textColor = .secondaryLabel
        loginLabel.textAlignment = .center
        containerView.addSubview(loginLabel)
        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        bioLabel.font = .systemFont(ofSize: 14)
        bioLabel.textColor = .label
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 0
        bioLabel.lineBreakMode = .byWordWrapping
        containerView.addSubview(bioLabel)
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        
        statsStackView.axis = .horizontal
        statsStackView.spacing = 40
        statsStackView.distribution = .fillEqually
        containerView.addSubview(statsStackView)
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }
        
        let followersLabel = createStatLabel(title: "followers", value: "0")
        let followingLabel = createStatLabel(title: "following", value: "0")
        let reposLabel = createStatLabel(title: "repos", value: "0")
        statsStackView.addArrangedSubview(followersLabel)
        statsStackView.addArrangedSubview(followingLabel)
        statsStackView.addArrangedSubview(reposLabel)
        
        if isCurrentUser {
            logoutButton.setTitle("profile.logout".localized, for: .normal)
            logoutButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            logoutButton.backgroundColor = .systemRed
            logoutButton.setTitleColor(.white, for: .normal)
            logoutButton.layer.cornerRadius = 8
            logoutButton.clipsToBounds = true
            logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
            containerView.addSubview(logoutButton)
            logoutButton.snp.makeConstraints { make in
                make.top.equalTo(statsStackView.snp.bottom).offset(40)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(50)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createStatLabel(title: String, value: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.text = value
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title.localized
        
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(titleLabel)
        
        return stackView
    }
    
    private func updateStats(followers: Int, following: Int, repos: Int) {
        if let followersStackView = statsStackView.arrangedSubviews[0] as? UIStackView,
           let followersLabel = followersStackView.arrangedSubviews[0] as? UILabel {
            followersLabel.text = "\(followers)"
        }
        
        if let followingStackView = statsStackView.arrangedSubviews[1] as? UIStackView,
           let followingLabel = followingStackView.arrangedSubviews[0] as? UILabel {
            followingLabel.text = "\(following)"
        }
        
        if let reposStackView = statsStackView.arrangedSubviews[2] as? UIStackView,
           let reposLabel = reposStackView.arrangedSubviews[0] as? UILabel {
            reposLabel.text = "\(repos)"
        }
    }
    
    // MARK: - Data Loading
    
    private func loadUserInfo() {
        let (currentUsername, _) = KeychainManager.shared.loadCredentials()
        let targetUsername = username ?? currentUsername ?? ""
        
        // 直接使用本地存储的用户名，不调用GitHub API
        // 创建一个简化的User对象，只包含必要的信息
        let user = User(
            id: 0,
            login: targetUsername,
            avatarUrl: "",
            name: targetUsername,
            bio: "",
            publicRepos: 0,
            followers: 0,
            following: 0,
            email: nil,
            location: nil
        )
        
        DispatchQueue.main.async {
            self.updateUI(with: user)
        }
    }
    
    private func updateUI(with user: User) {
        nameLabel.text = user.name ?? user.login
        loginLabel.text = "@\(user.login)"
        bioLabel.text = user.bio ?? ""
        updateStats(followers: user.followers, following: user.following, repos: user.publicRepos)
        
        if let avatarUrl = URL(string: user.avatarUrl) {
            avatarImageView.loadImage(from: avatarUrl)
        }
        
        if !isCurrentUser {
            title = user.name ?? user.login
        }
    }
    
    private func showError() {
        let alertController = UIAlertController(title: "error.title".localized, message: "error.message".localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized, style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc private func logoutButtonTapped() {
        let alertController = UIAlertController(title: "profile.logout".localized, message: "确定要退出登录吗?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "profile.logout".localized, style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func performLogout() {
        // 不再删除Keychain中的凭据，只跳转到登录页
        print("Logout: Navigating to login page without deleting credentials")
        
        // 跳转到登录页
        let loginVC = LoginViewController()
        if let navigationController = self.navigationController {
            // 先回到首页，然后push登录页，这样登录页会有返回按钮
            let homeVC = HomeViewController()
            navigationController.setViewControllers([homeVC, loginVC], animated: true)
        } else {
            // 如果没有navigationController，使用present方式
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        }
    }
}
