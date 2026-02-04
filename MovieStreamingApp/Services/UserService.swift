import Foundation
import CryptoKit

final class UserService {
    
    private let dao: UserDAO
    private let sessionKey = "com.app.currentSession"
    
    private(set) var currentSession: UserSession? {
        didSet {
            saveSession()
        }
    }
    
    init(dao: UserDAO = UserDAO()) {
        self.dao = dao
        loadSession()
    }
    
    // MARK: - Register
    
    func register(name: String, email: String, password: String) throws -> User {
        guard !email.isEmpty, !password.isEmpty, password.count >= 8 else {
            throw UserServiceError.invalidInput
        }
        
        if let _ = try dao.findByEmail(email) {
            throw UserServiceError.emailAlreadyExists
        }
        
        let hashedPassword = hashPassword(password)
        
        let now = Date()
        let user = User(
            id: UUID().uuidString,
            name: name,
            email: email,
            password: hashedPassword,
            createdAt: now,
            updatedAt: now
        )
        
        try dao.insert(user)
        
        let session = createSession(for: user)
        currentSession = session
        
        return user
    }
    
    // MARK: - Login
    
    func login(email: String, password: String) throws -> UserSession {
        guard let user = try dao.findByEmail(email) else {
            throw UserServiceError.invalidCredentials
        }
        
        guard verifyPassword(password, against: user.password) else {
            throw UserServiceError.invalidCredentials
        }
        
        let session = createSession(for: user)
        currentSession = session
        
        return session
    }
    
    // MARK: - Logout
    
    func logout() {
        currentSession = nil
    }
    
    // MARK: - Update
    
    func update(user: User) throws {
        try dao.update(user)
        
        if currentSession?.user.id == user.id {
            currentSession = UserSession(
                user: user,
                token: currentSession!.token,
                loginDate: currentSession!.loginDate,
                expiresAt: currentSession!.expiresAt
            )
        }
    }
    
    // MARK: - Queries
    
    func findById(_ id: String) throws -> User? {
        try dao.findById(id)
    }
    
    func getCurrentSession() -> UserSession? {
        guard let session = currentSession else { return nil }
        
        if session.isExpired {
            logout()
            return nil
        }
        
        return session
    }
    
    func isSessionValid() -> Bool {
        getCurrentSession() != nil
    }
    
    // MARK: - Private Helpers
    
    private func createSession(for user: User) -> UserSession {
        let token = generateSecureToken()
        let loginDate = Date()
        let expiresAt = Calendar.current.date(byAdding: .day, value: 30, to: loginDate)!
        
        return UserSession(
            user: user,
            token: token,
            loginDate: loginDate,
            expiresAt: expiresAt
        )
    }
    
    private func generateSecureToken() -> String {
        let randomData = (0..<32).map { _ in UInt8.random(in: 0...255) }
        return Data(randomData).base64EncodedString()
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    private func verifyPassword(_ password: String, against hash: String) -> Bool {
        hashPassword(password) == hash
    }
    
    // MARK: - Session Persistence
    
    private func saveSession() {
        guard let session = currentSession else {
            UserDefaults.standard.removeObject(forKey: sessionKey)
            return
        }
        
        do {
            let data = try JSONEncoder().encode(session)
            UserDefaults.standard.set(data, forKey: sessionKey)
        } catch {
            print("Erreur sauvegarde session:", error)
        }
    }
    
    private func loadSession() {
        guard let data = UserDefaults.standard.data(forKey: sessionKey) else {
            currentSession = nil
            return
        }
        
        do {
            let session = try JSONDecoder().decode(UserSession.self, from: data)
            
            if session.isExpired {
                currentSession = nil
            } else {
                currentSession = session
            }
        } catch {
            print("Erreur chargement session:", error)
            currentSession = nil
        }
    }
}

// MARK: - Errors

enum UserServiceError: LocalizedError {
    case invalidInput
    case emailAlreadyExists
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Email et mot de passe invalides"
        case .emailAlreadyExists:
            return "Email déjà utilisé"
        case .invalidCredentials:
            return "Identifiants incorrects"
        }
    }
}
