import UIKit
import SnapKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let biometricLoginButton = UIButton(type: .system)
    private let stackView = UIStackView()
    private let logoImageView = UIImageView()
    private let errorLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "login.title".localized
        setupUI()
        setupBiometricButton()
        loadSavedCredentials()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        // Add tap gesture recognizer to hide keyboard when tapping outside text fields
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        logoImageView.image = UIImage(systemName: "person.fill")
        logoImageView.tintColor = .systemBlue
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
        
        configureTextField(usernameTextField, placeholder: "login.username".localized, isSecureTextEntry: false)
        usernameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        stackView.addArrangedSubview(usernameTextField)
        
        configureTextField(passwordTextField, placeholder: "login.password".localized, isSecureTextEntry: true)
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        stackView.addArrangedSubview(passwordTextField)
        
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        stackView.addArrangedSubview(errorLabel)
        
        configureButton(loginButton, title: "login.loginButton".localized)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        stackView.addArrangedSubview(loginButton)
        
        configureButton(biometricLoginButton, title: "login.biometricLogin".localized)
        biometricLoginButton.addTarget(self, action: #selector(biometricLoginButtonTapped), for: .touchUpInside)
        biometricLoginButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        stackView.addArrangedSubview(biometricLoginButton)
        
        let registerButton = UIButton(type: .system)
        registerButton.setTitle("login.register".localized, for: .normal)
        registerButton.setTitleColor(.systemBlue, for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 16)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(registerButton)
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String, isSecureTextEntry: Bool) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = isSecureTextEntry
        textField.backgroundColor = .systemBackground
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.cornerRadius = 8
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
    }
    
    private func configureButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
    }
    
    private func setupBiometricButton() {
        let biometricManager = BiometricAuthManager.shared
        if biometricManager.isBiometricAvailable() && biometricManager.isBiometricEnrolled() {
            let biometricType = biometricManager.getBiometricTypeName()
            biometricLoginButton.setTitle("login.biometricLogin".localized + " (\(biometricType))", for: .normal)
            biometricLoginButton.isHidden = false
        } else {
            biometricLoginButton.isHidden = true
        }
    }
    
    // MARK: - Methods
    
    private func loadSavedCredentials() {
        let (username, _) = KeychainManager.shared.loadCredentials()
        if let username = username {
            usernameTextField.text = username
        }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        
        // Hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.errorLabel.isHidden = true
        }
    }
    
    private func performLogin(withUsername username: String, password: String) {
        // 从本地存储获取凭据进行校验
        let (storedUsername, storedPassword) = KeychainManager.shared.loadCredentials()
        
        // 校验用户名和密码
        if storedUsername == username && storedPassword == password {
            // 登录成功，跳转到首页
            DispatchQueue.main.async {
                let homeVC = HomeViewController()
                self.navigationController?.setViewControllers([homeVC], animated: true)
            }
        } else {
            // 登录失败，显示错误
            DispatchQueue.main.async {
                self.showError("login.error.invalidCredentials".localized)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("login.error.invalidCredentials".localized)
            return
        }
        
        performLogin(withUsername: username, password: password)
    }
    
    @objc private func registerButtonTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func biometricLoginButtonTapped() {
        let biometricManager = BiometricAuthManager.shared
        
        biometricManager.authenticateUser(reason: "biometric.prompt".localized) { [weak self] success, error in
            guard let self = self else { return }
            
            if success {
                // 生物识别成功，获取保存的凭据
                let (username, password) = KeychainManager.shared.loadCredentials()
                if let username = username, let password = password {
                    self.performLogin(withUsername: username, password: password)
                } else {
                    self.showError("login.error.invalidCredentials".localized)
                }
            } else {
                if let error = error as NSError? {
                    switch error.code {
                    case LAError.userCancel.rawValue:
                        break // 用户取消，不显示错误
                    case LAError.biometryLockout.rawValue:
                        self.showError("biometric.authenticationFailed".localized)
                    default:
                        self.showError("biometric.authenticationFailed".localized)
                    }
                }
            }
        }
    }
}
