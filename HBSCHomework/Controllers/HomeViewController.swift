import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var repositories: [Repository] = []
    private var isLoading = false
    private var currentPage = 1
    private let perPage = 20
    private var hasMoreRepositories = true
    
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    private var cancelButton: UIButton?
    private var loadingLabel: UILabel?
    private var currentDataTask: URLSessionDataTask?
    private var isShowingLoading = false
    private var isFirstTimeLoad = true
    
    private var errorContainerView: UIView?
    private var errorImageView: UIImageView?
    private var errorLabel: UILabel?
    private var retryButton: UIButton?
    private var isShowingError = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.isHidden = true
        loadPopularRepositories(page: currentPage)
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "home.title".localized
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.reuseIdentifier)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setupNavigationBar() {
        // Right Bar Button Items
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(profileButtonTapped))
        navigationItem.rightBarButtonItems = [profileButton, searchButton]
        

    }
    
    // MARK: - Data Loading
    
    private func loadPopularRepositories(page: Int = 1) {
        if page == 1 {
            repositories.removeAll()
            hasMoreRepositories = true
            showLoadingView()
        }
        
        isLoading = true
        
        currentDataTask?.cancel()
        
        currentDataTask = GitHubAPIService.shared.getPopularRepositories(page: page, perPage: perPage) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let repos):
                if page == 1 {
                    self.repositories = repos
                } else {
                    self.repositories.append(contentsOf: repos)
                }
                
                // Check if there are more repositories
                self.hasMoreRepositories = repos.count == self.perPage
            case .failure(let error):
                print("Failed to load popular repositories: \(error)")
                if page == 1 {
                    self.repositories = []
                }
                self.hasMoreRepositories = false
            }
            
            DispatchQueue.main.async {
                // Hide loading view for initial request
                if page == 1 {
                    self.hideLoadingView()
                    // Mark first time load as complete
                    self.isFirstTimeLoad = false
                }
                
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
                // Show error view if loading failed and it's the first page
                if page == 1 {
                    if self.repositories.isEmpty {
                        // If we have no repositories after loading, show error view
                        self.showErrorView()
                    } else {
                        // Hide error view if we have data
                        self.hideErrorView()
                        self.tableView.isHidden = false
                    }
                } else {
                    // For pagination, just hide tableView if no data
                    self.tableView.isHidden = self.repositories.isEmpty
                }
            }
        }
    }
    
    // MARK: - Loading View Methods
    
    private func createLoadingView(showCancelButton: Bool = true) {
        
        let newLoadingView = UIView()
        newLoadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView = newLoadingView
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        newLoadingView.addSubview(containerView)
        
        let newActivityIndicator = UIActivityIndicatorView(style: .large)
        newActivityIndicator.color = .systemBlue
        containerView.addSubview(newActivityIndicator)
        activityIndicator = newActivityIndicator
        
        let newLoadingLabel = UILabel()
        newLoadingLabel.text = "loading.loading".localized
        newLoadingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        newLoadingLabel.textColor = .label
        containerView.addSubview(newLoadingLabel)
        loadingLabel = newLoadingLabel
        
        if showCancelButton {
            let newCancelButton = UIButton(type: .system)
            newCancelButton.setTitle("loading.cancel.loading".localized, for: .normal)
            newCancelButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            newCancelButton.setTitleColor(.systemBlue, for: .normal)
            newCancelButton.addTarget(self, action: #selector(cancelLoading), for: .touchUpInside)
            containerView.addSubview(newCancelButton)
            cancelButton = newCancelButton
            
            newCancelButton.snp.makeConstraints {
                $0.centerX.equalTo(containerView)
                $0.top.equalTo(newLoadingLabel.snp.bottom).offset(16)
                $0.bottom.equalTo(containerView).offset(-16)
            }
        }
        
        containerView.snp.makeConstraints {
            $0.centerX.centerY.equalTo(newLoadingView)
            $0.leading.greaterThanOrEqualTo(newLoadingView).offset(40)
            $0.trailing.lessThanOrEqualTo(newLoadingView).offset(-40)
            $0.width.equalTo(200)
        }
        
        newActivityIndicator.snp.makeConstraints {
            $0.centerX.equalTo(containerView)
            $0.top.equalTo(containerView).offset(20)
        }
        
        newLoadingLabel.snp.makeConstraints {
            $0.centerX.equalTo(containerView)
            $0.top.equalTo(newActivityIndicator.snp.bottom).offset(12)
            
            // If no cancel button, make label bottom aligned
            if !showCancelButton {
                $0.bottom.equalTo(containerView).offset(-20)
            }
        }
    }

    
    private func showLoadingView() {
        if isShowingLoading {
            return
        }
        
        // Create loading view with or without cancel button based on isFirstTimeLoad
        createLoadingView(showCancelButton: !isFirstTimeLoad)
        
        view.addSubview(loadingView!)
        
        loadingView!.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        activityIndicator?.startAnimating()
        isShowingLoading = true
    }
    
    private func hideLoadingView() {
        if !isShowingLoading {
            return
        }
        
        activityIndicator?.stopAnimating()
        loadingView?.removeFromSuperview()
        isShowingLoading = false
    }
    
    @objc private func cancelLoading() {
        // Cancel the current data task
        currentDataTask?.cancel()
        currentDataTask = nil
        
        hideLoadingView()
        
        isLoading = false
        refreshControl.endRefreshing()
    }
    
    // MARK: - Error View Methods
    
    private func createErrorView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemBackground
        errorContainerView = backgroundView
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        backgroundView.addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(40)
            $0.trailing.lessThanOrEqualToSuperview().offset(-40)
            $0.width.equalTo(280)
        }
        
        let errorImage = UIImage(systemName: "exclamationmark.triangle.fill")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: errorImage)
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)
        errorImageView = imageView
        
        let errorLabel = UILabel()
        errorLabel.text = "加载失败，请重试"
        errorLabel.textAlignment = .center
        errorLabel.textColor = .label
        errorLabel.font = .systemFont(ofSize: 16, weight: .medium)
        errorLabel.numberOfLines = 0
        containerView.addSubview(errorLabel)
        self.errorLabel = errorLabel
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("重试", for: .normal)
        retryButton.setTitleColor(.systemBlue, for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        retryButton.layer.cornerRadius = 8
        retryButton.layer.borderWidth = 1
        retryButton.layer.borderColor = UIColor.systemBlue.cgColor
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        containerView.addSubview(retryButton)
        self.retryButton = retryButton
        
        imageView.snp.makeConstraints {
            $0.centerX.equalTo(containerView)
            $0.top.equalTo(containerView).offset(24)
            $0.width.height.equalTo(64)
        }
        
        errorLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(20)
            $0.trailing.equalTo(containerView).offset(-20)
            $0.top.equalTo(imageView.snp.bottom).offset(16)
        }
        
        retryButton.snp.makeConstraints {
            $0.centerX.equalTo(containerView)
            $0.top.equalTo(errorLabel.snp.bottom).offset(20)
            $0.bottom.equalTo(containerView).offset(-24)
            $0.width.equalTo(120)
            $0.height.equalTo(44)
        }
    }
    
    private func showErrorView() {
        if isShowingError {
            return
        }
        
        createErrorView()
        
        view.addSubview(errorContainerView!)
        
        errorContainerView!.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        isShowingError = true
        tableView.isHidden = true
    }
    
    private func hideErrorView() {
        if !isShowingError {
            return
        }
        
        errorContainerView?.removeFromSuperview()
        isShowingError = false
    }
    
    @objc private func retryButtonTapped() {
        hideErrorView()
        // Retry loading data
        refreshData()
    }
    
    // MARK: - Actions
    
    @objc private func refreshData() {
        currentPage = 1
        loadPopularRepositories(page: currentPage)
    }
    
    @objc private func searchButtonTapped() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func profileButtonTapped() {
        let (username, _) = KeychainManager.shared.loadCredentials()
        if username != nil {
            let profileVC = ProfileViewController()
            navigationController?.pushViewController(profileVC, animated: true)
        } else {
            let loginVC = LoginViewController()
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "recently.updated.popular.repos".localized
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "recently.updated.popular.repos".localized
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if repositories.isEmpty {
            return 0
        }
        // Add an extra row for loading indicator if there are more repositories
        return repositories.count + (hasMoreRepositories ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 安全检查：确保indexPath.row不超出repositories数组范围
        if indexPath.row >= repositories.count {
            // Loading indicator cell or empty state
            if hasMoreRepositories {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                let activityIndicator = UIActivityIndicatorView(style: .medium)
                activityIndicator.startAnimating()
                cell.accessoryView = activityIndicator
                cell.textLabel?.text = "加载中..."
                cell.textLabel?.textColor = .secondaryLabel
                return cell
            } else {
                // 如果没有更多数据，返回一个空单元格
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.isHidden = true
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.reuseIdentifier, for: indexPath) as! RepositoryTableViewCell
            let repository = repositories[indexPath.row]
            cell.configure(with: repository)
            
            // Trigger load more when approaching the end
            if indexPath.row == repositories.count - 3 && !isLoading && hasMoreRepositories {
                currentPage += 1
                loadPopularRepositories(page: currentPage)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < repositories.count {
            let repository = repositories[indexPath.row]
            // Open repository in Safari
            if let url = URL(string: repository.htmlUrl) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
