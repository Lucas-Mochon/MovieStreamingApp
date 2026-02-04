import Foundation

struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var password: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String, name: String, email: String, password: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
