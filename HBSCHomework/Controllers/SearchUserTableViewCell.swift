import UIKit
import SnapKit

class SearchUserTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "SearchUserTableViewCell"
    
    // MARK: - Properties
    
    private let avatarImageView = AsyncImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let infoLabel = UILabel()
    private let stackView = UIStackView()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.clipsToBounds = true
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(60)
        }
        
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = .label
        stackView.addArrangedSubview(nameLabel)
        
        loginLabel.font = .systemFont(ofSize: 14)
        loginLabel.textColor = .secondaryLabel
        stackView.addArrangedSubview(loginLabel)
        
        infoLabel.font = .systemFont(ofSize: 12)
        infoLabel.textColor = .tertiaryLabel
        stackView.addArrangedSubview(infoLabel)
    }
    
    // MARK: - Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.reset()
    }
    
    func configure(with user: SearchUser) {
        nameLabel.text = user.login
        loginLabel.text = "@\(user.login)"
        infoLabel.text = "Type: \(user.type) · Score: \(String(format: "%.2f", user.score))"
        
        if let avatarUrl = URL(string: user.avatarUrl) {
            avatarImageView.loadImage(from: avatarUrl)
        }
    }
}
