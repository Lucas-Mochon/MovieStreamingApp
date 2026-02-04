import Foundation

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let persistence = PersistenceService.shared
    
    func register(name: String, email: String, password: String) throws -> User {
        let existingUsers = persistence.getAllUsers()
        if existingUsers.contains(where: { $0.email == email }) {
            throw APIError.unknown
        }
        
        guard password.count >= 6 else {
            throw APIError.unknown
        }
        
        let user = User(name: name, email: email, password: password)
        try persistence.saveUser(user)
        
        return user
    }
    
    func login(email: String, password: String) throws -> UserSession {
        let users = persistence.getAllUsers()
        
        guard let user = users.first(where: { $0.email == email }) else {
            throw APIError.unauthorized
        }
        
        guard user.password == password else {
            throw APIError.unauthorized
        }
        
        let session = UserSession(
            user: user,
            token: UUID().uuidString,
            loginDate: Date()
        )
        
        try persistence.saveSession(session)
        
        return session
    }
    
    func logout() throws {
        persistence.clearSession()
    }
    
    func getCurrentSession() -> UserSession? {
        persistence.getActiveSession()
    }
    
    func updateUser(_ user: User) throws {
        try persistence.saveUser(user)
        
        if var session = persistence.getActiveSession() {
            session = UserSession(user: user, token: session.token, loginDate: session.loginDate)
            try persistence.saveSession(session)
        }
    }
}
