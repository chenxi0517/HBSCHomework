import UIKit
import SnapKit

class CardView: UIView {
    
    // MARK: - Properties
    
    private let contentView = UIView()
    private let shadowView = UIView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // 配置阴影视图
        addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 配置内容视图
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 更新阴影
        updateShadow()
        
        // 监听主题变化
        NotificationCenter.default.addObserver(self, selector: #selector(updateForThemeChange), name: .init(rawValue: "kThemeChangedNotification"), object: nil)
    }
    
    // MARK: - Shadow Configuration
    
    private func updateShadow() {
        shadowView.layer.cornerRadius = 12
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowRadius = 8
        shadowView.layer.masksToBounds = false
    }
    
    @objc private func updateForThemeChange() {
        contentView.backgroundColor = .systemBackground
    }
    
    // MARK: - Content Management
    
    func addSubviewToContent(_ view: UIView) {
        contentView.addSubview(view)
    }
    
    func addSubviewsToContent(_ views: [UIView]) {
        views.forEach { contentView.addSubview($0) }
    }
    
    // MARK: - Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadow()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            contentView.backgroundColor = .systemBackground
        }
    }
}
