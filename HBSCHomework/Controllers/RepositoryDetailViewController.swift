import UIKit
import SnapKit

class RepositoryDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let username: String
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var repositories: [Repository] = []
    private var isLoading = false
    private var currentPage = 1
    private let perPage = 20
    private var hasMoreRepositories = true
    
    // MARK: - Initialization
    
    init(username: String) {
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRepositories()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "\(username)'s Repositories"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.reuseIdentifier)
        refreshControl.addTarget(self, action: #selector(refreshRepositories), for: .valueChanged)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadRepositories(page: Int = 1) {
        if page == 1 {
            refreshControl.beginRefreshing()
            repositories.removeAll()
            hasMoreRepositories = true
        }
        
        isLoading = true
        
        GitHubAPIService.shared.getRepositories(username: username, page: page, perPage: perPage) { [weak self] result in
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
                print("Failed to load repositories: \(error)")
                if page == 1 {
                    self.repositories = []
                }
                self.hasMoreRepositories = false
            }
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshRepositories() {
        currentPage = 1
        loadRepositories(page: currentPage)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension RepositoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Add an extra row for loading indicator if there are more repositories
        return repositories.count + (hasMoreRepositories ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == repositories.count {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            cell.accessoryView = activityIndicator
            cell.textLabel?.text = "加载中..."
            cell.textLabel?.textColor = .secondaryLabel
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.reuseIdentifier, for: indexPath) as! RepositoryTableViewCell
            let repository = repositories[indexPath.row]
            cell.configure(with: repository)
            
            // Trigger load more when approaching the end
            if indexPath.row == repositories.count - 3 && !isLoading && hasMoreRepositories {
                currentPage += 1
                loadRepositories(page: currentPage)
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

// MARK: - RepositoryTableViewCell

class RepositoryTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "RepositoryTableViewCell"
    
    // MARK: - Properties
    
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let statsLabel = UILabel()
    private let languageLabel = UILabel()
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
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        stackView.addArrangedSubview(nameLabel)
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        stackView.addArrangedSubview(descriptionLabel)
        
        let statsLanguageStackView = UIStackView()
        statsLanguageStackView.axis = .horizontal
        statsLanguageStackView.spacing = 12
        statsLanguageStackView.alignment = .center
        stackView.addArrangedSubview(statsLanguageStackView)
        
        statsLabel.font = .systemFont(ofSize: 12)
        statsLabel.textColor = .tertiaryLabel
        statsLanguageStackView.addArrangedSubview(statsLabel)
        
        languageLabel.font = .systemFont(ofSize: 12)
        languageLabel.textColor = .tertiaryLabel
        languageLabel.layer.cornerRadius = 4
        languageLabel.layer.borderWidth = 1
        languageLabel.layer.borderColor = UIColor.tertiaryLabel.cgColor
        languageLabel.textAlignment = .center
        languageLabel.clipsToBounds = true
        languageLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(60)
        }
        statsLanguageStackView.addArrangedSubview(languageLabel)
    }
    
    // MARK: - Methods
    
    func configure(with repository: Repository) {
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description ?? ""
        
        let stars = repository.stargazersCount
        let forks = repository.forksCount
        statsLabel.text = "⭐️ \(stars) · 🍴 \(forks)"
        
        if let language = repository.language {
            languageLabel.text = language
            languageLabel.isHidden = false
        } else {
            languageLabel.isHidden = true
        }
    }
}
