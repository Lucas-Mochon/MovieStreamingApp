import Foundation

struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var password: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, name: String, email: String, password: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct UserSession: Codable {
    let user: User
    let token: String
    let loginDate: Date
}
