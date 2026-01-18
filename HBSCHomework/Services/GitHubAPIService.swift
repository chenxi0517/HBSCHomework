import Foundation

class GitHubAPIService {
    
    // MARK: - Singleton
    
    static let shared = GitHubAPIService()
    private init() {}
    
    // MARK: - Constants
    
    private let baseURL = "https://api.github.com"
    private let session = URLSession.shared
    
    // MARK: - User Methods
    
    /// 获取用户信息
    func getUserInfo(username: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(username)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    /// 搜索用户
    func searchUsers(query: String, page: Int = 1, perPage: Int = 10, completion: @escaping (Result<[SearchUser], Error>) -> Void) -> URLSessionDataTask? {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search/users?q=\(encodedQuery)&page=\(page)&per_page=\(perPage)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return nil
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                completion(.success(searchResponse.items))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
        return task
    }
    
    /// 获取用户仓库列表
    func getRepositories(username: String, page: Int = 1, perPage: Int = 20, completion: @escaping (Result<[Repository], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(username)/repos?page=\(page)&per_page=\(perPage)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                // 设置日期解码格式
                decoder.dateDecodingStrategy = .iso8601
                let repositories = try decoder.decode([Repository].self, from: data)
                completion(.success(repositories))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Helper Structs
    
    private struct SearchResponse: Codable {
        let totalCount: Int
        let items: [SearchUser]
        
        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case items
        }
    }
    
    private struct RepositorySearchResponse: Codable {
        let totalCount: Int
        let items: [Repository]
        
        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case items
        }
    }
    
    /// 获取热门仓库（star > 10000且最近3天有更新）
    func getPopularRepositories(page: Int = 1, perPage: Int = 20, completion: @escaping (Result<[Repository], Error>) -> Void) -> URLSessionDataTask? {
        // 计算3天前的日期
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let dateFormatter = ISO8601DateFormatter()
        let threeDaysAgoString = dateFormatter.string(from: threeDaysAgo)
        
        // 构建搜索URL，使用stars:>10000和pushed:>3days前的日期
        let urlString = "\(baseURL)/search/repositories?q=stars:>10000+pushed:>\(threeDaysAgoString)&sort=updated&order=desc&page=\(page)&per_page=\(perPage)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return nil
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let searchResponse = try decoder.decode(RepositorySearchResponse.self, from: data)
                completion(.success(searchResponse.items))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
        return task
    }
    
    /// 搜索仓库
    func searchRepositories(query: String, page: Int = 1, perPage: Int = 20, completion: @escaping (Result<[Repository], Error>) -> Void) -> URLSessionDataTask? {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search/repositories?q=\(encodedQuery)&page=\(page)&per_page=\(perPage)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return nil
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let searchResponse = try decoder.decode(RepositorySearchResponse.self, from: data)
                completion(.success(searchResponse.items))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
        return task
    }
}
