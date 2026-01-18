import Foundation

struct User: Codable {
    let id: Int
    let login: String
    let avatarUrl: String
    let name: String?
    let bio: String?
    let publicRepos: Int
    let followers: Int
    let following: Int
    let email: String?
    let location: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case name
        case bio
        case publicRepos = "public_repos"
        case followers
        case following
        case email
        case location
    }
}