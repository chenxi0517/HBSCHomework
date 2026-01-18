import UIKit
import SnapKit

class SearchViewController: UIViewController {
    
    // MARK: - Enums
    
    enum SearchType {
        case user
        case repository
    }
    
    // MARK: - Properties
    
    private let searchBar = UISearchBar()
    private let searchTypeSegmentedControl = UISegmentedControl(items: ["search.type.user".localized, "search.type.repository".localized])
    private let tableView = UITableView()
    private var userSearchResults: [SearchUser] = []
    private var repositorySearchResults: [Repository] = []
    private var recentSearches: [String] = []
    private let recentSearchesKey = "kRecentSearchesKey"
    private var currentSearchType: SearchType = .user
    
    // Pagination properties
    private var currentQuery: String = ""
    private var currentPage: Int = 1
    private let perPage: Int = 20
    private var isLoadingMore: Bool = false
    private var hasMoreResults: Bool = true
    
    // Loading view properties
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    private var cancelButton: UIButton?
    private var currentDataTask: URLSessionDataTask?
    private var isShowingLoading: Bool = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRecentSearches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "search.title".localized
        
        searchBar.delegate = self
        searchBar.placeholder = "search.placeholder".localized
        navigationItem.titleView = searchBar
        
        searchTypeSegmentedControl.selectedSegmentIndex = 0
        searchTypeSegmentedControl.addTarget(self, action: #selector(searchTypeChanged(_:)), for: .valueChanged)
        view.addSubview(searchTypeSegmentedControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchUserTableViewCell.self, forCellReuseIdentifier: SearchUserTableViewCell.reuseIdentifier)
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.reuseIdentifier)
        tableView.register(RecentSearchTableViewCell.self, forCellReuseIdentifier: RecentSearchTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        
        searchTypeSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchTypeSegmentedControl.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // MARK: - Data Management
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }
    
    private func saveRecentSearch(_ search: String) {
        // Remove if already exists
        if let index = recentSearches.firstIndex(of: search) {
            recentSearches.remove(at: index)
        }
        
        // Add to beginning
        recentSearches.insert(search, at: 0)
        
        // Keep only last 10 searches
        if recentSearches.count > 10 {
            recentSearches.removeLast(recentSearches.count - 10)
        }
        
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    private func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
        tableView.reloadData()
    }
    
    private func performSearch(_ query: String, page: Int = 1) {
        // If it's a new search, reset pagination and results
        if page == 1 {
            currentQuery = query
            currentPage = 1
            userSearchResults.removeAll()
            repositorySearchResults.removeAll()
            hasMoreResults = true
            
            // Show loading view for initial search
            showLoadingView()
        }
        
        isLoadingMore = true
        
        switch currentSearchType {
        case .user:
            // Cancel any ongoing user search
            currentDataTask?.cancel()
            
            currentDataTask = GitHubAPIService.shared.searchUsers(query: query, page: page, perPage: perPage) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let users):
                    if page == 1 {
                        self.userSearchResults = users
                    } else {
                        self.userSearchResults.append(contentsOf: users)
                    }
                    
                    // Check if there are more results
                    self.hasMoreResults = users.count == self.perPage
                case .failure(let error):
                    print("User search failed: \(error)")
                    if page == 1 {
                        self.userSearchResults = []
                    }
                    self.hasMoreResults = false
                    
                    DispatchQueue.main.async {
                        self.showErrorTip()
                    }
                }
                
                self.isLoadingMore = false
                
                DispatchQueue.main.async {
                    // Hide loading view for initial search
                    if page == 1 {
                        self.hideLoadingView()
                    }
                    self.tableView.reloadData()
                }
            }
        case .repository:
            // Cancel any ongoing repository search
            currentDataTask?.cancel()
            
            // Perform repository search
            currentDataTask = GitHubAPIService.shared.searchRepositories(query: query, page: page, perPage: perPage) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let repositories):
                    if page == 1 {
                        self.repositorySearchResults = repositories
                    } else {
                        self.repositorySearchResults.append(contentsOf: repositories)
                    }
                    
                    // Check if there are more results
                    self.hasMoreResults = repositories.count == self.perPage
                case .failure(let error):
                    print("Repository search failed: \(error)")
                    if page == 1 {
                        self.repositorySearchResults = []
                    }
                    self.hasMoreResults = false
                    
                    // Show error tip
                    DispatchQueue.main.async {
                        self.showErrorTip()
                    }
                }
                
                self.isLoadingMore = false
                
                DispatchQueue.main.async {
                    // Hide loading view for initial search
                    if page == 1 {
                        self.hideLoadingView()
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func loadMoreResults() {
        if isLoadingMore || !hasMoreResults || currentQuery.isEmpty {
            return
        }
        
        currentPage += 1
        performSearch(currentQuery, page: currentPage)
    }
    
    // MARK: - Error Handling
    
    private func showErrorTip(message: String = "加载失败") {
        let toastView = UIView()
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastView.layer.cornerRadius = 20
        toastView.clipsToBounds = true
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        toastView.addSubview(label)
        
        view.addSubview(toastView)
        
        toastView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            $0.height.equalTo(40)
            $0.leading.greaterThanOrEqualToSuperview().offset(40)
            $0.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
        
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        toastView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toastView.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3, animations: {
                toastView.alpha = 0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Loading View Methods
    
    private func createLoadingView() {
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
        
        let loadingLabel = UILabel()
        loadingLabel.text = "loading.search".localized
        loadingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        loadingLabel.textColor = .label
        containerView.addSubview(loadingLabel)
        
        let newCancelButton = UIButton(type: .system)
        newCancelButton.setTitle("loading.cancel.search".localized, for: .normal)
        newCancelButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        newCancelButton.setTitleColor(.systemBlue, for: .normal)
        newCancelButton.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        containerView.addSubview(newCancelButton)
        cancelButton = newCancelButton
        
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
        
        loadingLabel.snp.makeConstraints {
            $0.centerX.equalTo(containerView)
            $0.top.equalTo(newActivityIndicator.snp.bottom).offset(12)
        }
        
        newCancelButton.snp.makeConstraints {
            $0.centerX.equalTo(containerView)
            $0.top.equalTo(loadingLabel.snp.bottom).offset(16)
            $0.bottom.equalTo(containerView).offset(-16)
        }
    }
    
    private func showLoadingView() {
        if isShowingLoading {
            return
        }
        
        if loadingView == nil {
            createLoadingView()
        }
        
        view.addSubview(loadingView!)
        
        // Set constraints for loading view to fill the entire parent view
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
    
    @objc private func cancelSearch() {
        // Cancel the current data task
        currentDataTask?.cancel()
        currentDataTask = nil
        
        // Hide loading view
        hideLoadingView()
        
        // Reset loading state
        isLoadingMore = false
    }
    
    // MARK: - Search Type Handling
    
    @objc private func searchTypeChanged(_ sender: UISegmentedControl) {
        // Update search type based on selected segment
        currentSearchType = sender.selectedSegmentIndex == 0 ? .user : .repository
        
        // Reset search results when type changes
        if !currentQuery.isEmpty {
            performSearch(currentQuery)
        }
        
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        saveRecentSearch(query)
        performSearch(query)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            userSearchResults.removeAll()
            repositorySearchResults.removeAll()
            tableView.reloadData()
        } else {
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        userSearchResults.removeAll()
        repositorySearchResults.removeAll()
        currentQuery = ""
        currentPage = 1
        isLoadingMore = false
        hasMoreResults = true
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let hasSearchResults = currentSearchType == .user ? !userSearchResults.isEmpty : !repositorySearchResults.isEmpty
        if hasSearchResults {
            return 1
        } else {
            return recentSearches.isEmpty ? 1 : 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hasSearchResults = currentSearchType == .user ? !userSearchResults.isEmpty : !repositorySearchResults.isEmpty
        if hasSearchResults {
            // Get the current results based on search type
            let resultsCount = currentSearchType == .user ? userSearchResults.count : repositorySearchResults.count
            // Add an extra row for loading indicator if there are more results
            return resultsCount + (hasMoreResults ? 1 : 0)
        } else {
            switch section {
            case 0:
                return recentSearches.count
            case 1:
                return 1 // Clear history button
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hasSearchResults = currentSearchType == .user ? !userSearchResults.isEmpty : !repositorySearchResults.isEmpty
        if hasSearchResults {
            // Get the current results based on search type
            let resultsCount = currentSearchType == .user ? userSearchResults.count : repositorySearchResults.count
            
            // Check if we're at the last row for loading indicator
            if indexPath.row == resultsCount {
                // Loading indicator cell
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                let activityIndicator = UIActivityIndicatorView(style: .medium)
                activityIndicator.startAnimating()
                cell.accessoryView = activityIndicator
                cell.textLabel?.text = "加载中..."
                cell.textLabel?.textColor = .secondaryLabel
                return cell
            } else {
                // Regular search result cell
                switch currentSearchType {
                case .user:
                    let cell = tableView.dequeueReusableCell(withIdentifier: SearchUserTableViewCell.reuseIdentifier, for: indexPath) as! SearchUserTableViewCell
                    let user = userSearchResults[indexPath.row]
                    cell.configure(with: user)
                    
                    // Trigger load more when approaching the end
                    if indexPath.row == userSearchResults.count - 3 && !isLoadingMore && hasMoreResults {
                        loadMoreResults()
                    }
                    
                    return cell
                case .repository:
                    let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.reuseIdentifier, for: indexPath) as! RepositoryTableViewCell
                    let repository = repositorySearchResults[indexPath.row]
                    cell.configure(with: repository)
                    
                    // Trigger load more when approaching the end
                    if indexPath.row == repositorySearchResults.count - 3 && !isLoadingMore && hasMoreResults {
                        loadMoreResults()
                    }
                    
                    return cell
                }
            }
        } else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchTableViewCell.reuseIdentifier, for: indexPath) as! RecentSearchTableViewCell
                let search = recentSearches[indexPath.row]
                cell.configure(with: search)
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "search.clearHistory".localized
                cell.textLabel?.textColor = .systemBlue
                cell.textLabel?.textAlignment = .center
                return cell
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Additional check for when user scrolls to bottom
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 2 && !isLoadingMore && hasMoreResults {
            loadMoreResults()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let hasSearchResults = currentSearchType == .user ? !userSearchResults.isEmpty : !repositorySearchResults.isEmpty
        if !hasSearchResults {
            switch section {
            case 0:
                return recentSearches.isEmpty ? nil : "search.recent".localized
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let hasSearchResults = currentSearchType == .user ? !userSearchResults.isEmpty : !repositorySearchResults.isEmpty
        if hasSearchResults {
            switch currentSearchType {
            case .user:
                return 80
            case .repository:
                return 120
            }
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let hasSearchResults = currentSearchType == .user ? !userSearchResults.isEmpty : !repositorySearchResults.isEmpty
        if hasSearchResults {
            switch currentSearchType {
            case .user:
                // Get the selected user
                let user = userSearchResults[indexPath.row]
                // Navigate to repository detail page for this user
                let repoDetailVC = RepositoryDetailViewController(username: user.login)
                navigationController?.pushViewController(repoDetailVC, animated: true)
            case .repository:
                // Get the selected repository
                let repository = repositorySearchResults[indexPath.row]
                // Open repository in Safari
                if let url = URL(string: repository.htmlUrl) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else {
            if indexPath.section == 0 {
                let search = recentSearches[indexPath.row]
                searchBar.text = search
                performSearch(search)
            } else {
                clearRecentSearches()
            }
        }
    }
}

// MARK: - RecentSearchTableViewCell

class RecentSearchTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "RecentSearchTableViewCell"
    
    // MARK: - Properties
    
    private let searchLabel = UILabel()
    private let iconImageView = UIImageView()
    
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
        // Icon Image View
        iconImageView.image = UIImage(systemName: "clock.fill")
        iconImageView.tintColor = .secondaryLabel
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(20)
        }
        
        // Search Label
        searchLabel.font = .systemFont(ofSize: 16)
        searchLabel.textColor = .label
        contentView.addSubview(searchLabel)
        searchLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Methods
    
    func configure(with search: String) {
        searchLabel.text = search
    }
}
