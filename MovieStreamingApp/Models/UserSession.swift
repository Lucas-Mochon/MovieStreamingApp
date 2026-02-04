import Foundation

struct UserSession: Codable {
    let user: User
    let token: String
    let loginDate: Date
}
