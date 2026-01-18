import UIKit
import SnapKit

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let registerButton = UIButton(type: .system)
    private let loginButton = UIButton(type: .system)
    private let stackView = UIStackView()
    private let logoImageView = UIImageView()
    private let errorLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        title = "login.title".localized
        
        logoImageView.image = UIImage(systemName: "person.badge.plus.fill")
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
        
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        stackView.addArrangedSubview(errorLabel)
        
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
        
        configureTextField(confirmPasswordTextField, placeholder: "login.confirmPassword".localized, isSecureTextEntry: true)
        confirmPasswordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        stackView.addArrangedSubview(confirmPasswordTextField)
        
        configureButton(registerButton, title: "login.register".localized)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        registerButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        stackView.addArrangedSubview(registerButton)
        
        loginButton.setTitle("login.alreadyHaveAccount".localized, for: .normal)
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(loginButton)
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
    
    // MARK: - Methods
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        
        // Hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.errorLabel.isHidden = true
        }
    }
    
    private func validateForm() -> Bool {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showError("register.error.usernameEmpty".localized)
            return false
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError("register.error.passwordEmpty".localized)
            return false
        }
        
        guard password.count >= 6 else {
            showError("register.error.passwordTooShort".localized)
            return false
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showError("register.error.confirmPasswordEmpty".localized)
            return false
        }
        
        guard password == confirmPassword else {
            showError("register.error.passwordMismatch".localized)
            return false
        }
        
        return true
    }
    
    private func performRegister(withUsername username: String, password: String) {
        // 检查用户名是否已存在
        let (storedUsername, _) = KeychainManager.shared.loadCredentials()
        if storedUsername == username {
            showError("register.error.usernameExists".localized)
            return
        }
        
        // 存储注册信息
        let success = KeychainManager.shared.saveCredentials(username: username, password: password)
        
        if success {
            // 注册成功，返回登录页
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            showError("register.error.failed".localized)
        }
    }
    
    // MARK: - Actions
    
    @objc private func registerButtonTapped() {
        guard validateForm() else {
            return
        }
        
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        
        performRegister(withUsername: username, password: password)
    }
    
    @objc private func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
