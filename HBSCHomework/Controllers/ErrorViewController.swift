import UIKit
import SnapKit

class ErrorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let errorImageView = UIImageView()
    private let errorTitleLabel = UILabel()
    private let errorMessageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private let stackView = UIStackView()
    
    private var errorTitle: String
    private var errorMessage: String
    private var retryAction: (() -> Void)?
    private var backAction: (() -> Void)?
    
    // MARK: - Initialization
    
    init(title: String = "error.title".localized, message: String = "error.message".localized, retryAction: (() -> Void)? = nil, backAction: (() -> Void)? = nil) {
        self.errorTitle = title
        self.errorMessage = message
        self.retryAction = retryAction
        self.backAction = backAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Error Image View
        errorImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        errorImageView.tintColor = .systemOrange
        errorImageView.contentMode = .scaleAspectFit
        
        // Error Title Label
        errorTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        errorTitleLabel.textColor = .label
        errorTitleLabel.textAlignment = .center
        errorTitleLabel.text = errorTitle
        
        // Error Message Label
        errorMessageLabel.font = .systemFont(ofSize: 16)
        errorMessageLabel.textColor = .secondaryLabel
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.text = errorMessage
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.lineBreakMode = .byWordWrapping
        
        // Stack View
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        // Add views to stack view
        stackView.addArrangedSubview(errorImageView)
        errorImageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.centerX.equalToSuperview()
        }
        
        stackView.addArrangedSubview(errorTitleLabel)
        stackView.addArrangedSubview(errorMessageLabel)
        
        // Buttons Stack View
        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 12
        buttonsStackView.alignment = .fill
        
        // Retry Button
        if retryAction != nil {
            configureButton(retryButton, title: "error.retry".localized)
            retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(retryButton)
            retryButton.snp.makeConstraints { make in
                make.height.equalTo(50)
            }
        }
        
        // Back Button
        configureButton(backButton, title: "error.back".localized)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        stackView.addArrangedSubview(buttonsStackView)
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
    }
    
    private func configureButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
    }
    
    // MARK: - Actions
    
    @objc private func retryButtonTapped() {
        retryAction?()
    }
    
    @objc private func backButtonTapped() {
        if let backAction = backAction {
            backAction()
        } else {
            // Default back action
            navigationController?.popViewController(animated: true)
            
            // If not in navigation stack, dismiss
            if navigationController == nil {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Methods
    
    func updateError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        
        errorTitleLabel.text = errorTitle
        errorMessageLabel.text = errorMessage
    }
}
