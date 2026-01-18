import UIKit
import SDWebImage
import SnapKit

class AsyncImageView: UIImageView {
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let placeholderImage: UIImage?
    
    init(placeholderImage: UIImage? = nil) {
        self.placeholderImage = placeholderImage
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        self.placeholderImage = nil
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        
        activityIndicator.color = .secondaryLabel
        addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        image = placeholderImage
    }
    
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        // 显示加载指示器
        activityIndicator.startAnimating()
        
        // 使用SDWebImage加载图片
        self.sd_setImage(with: url, placeholderImage: placeholder ?? self.placeholderImage, options: [.highPriority, .refreshCached]) { [weak self] (image, error, cacheType, imageURL) in
            // 停止加载指示器
            self?.activityIndicator.stopAnimating()
            
            if let error = error {
                print("Image loading error: \(error)")
            }
        }
    }
    
    func cancelLoading() {
        // 取消SDWebImage的图片加载
        self.sd_cancelCurrentImageLoad()
        activityIndicator.stopAnimating()
    }
    
    /// 重置ImageView状态，用于重用时调用
    func reset() {
        cancelLoading()
        image = placeholderImage
    }
}