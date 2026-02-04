import Foundation

@MainActor
final class PersistenceService {
    static let shared = PersistenceService()
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveUser(_ user: User) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        userDefaults.set(data, forKey: "user_\(user.id)")
    }
    
    func getUser(id: String) -> User? {
        guard let data = userDefaults.data(forKey: "user_\(id)") else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(User.self, from: data)
    }
    
    func getAllUsers() -> [User] {
        let decoder = JSONDecoder()
        var users: [User] = []
        
        for key in userDefaults.dictionaryRepresentation().keys {
            if key.hasPrefix("user_"), let data = userDefaults.data(forKey: key) {
                if let user = try? decoder.decode(User.self, from: data) {
                    users.append(user)
                }
            }
        }
        
        return users
    }
    
    func deleteUser(id: String) {
        userDefaults.removeObject(forKey: "user_\(id)")
    }
    
    
    func saveSession(_ session: UserSession) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(session)
        userDefaults.set(data, forKey: "active_session")
    }
    
    func getActiveSession() -> UserSession? {
        guard let data = userDefaults.data(forKey: "active_session") else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(UserSession.self, from: data)
    }
    
    func clearSession() {
        userDefaults.removeObject(forKey: "active_session")
    }
    
    
    func saveFavorite(_ favorite: Favorite) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(favorite)
        userDefaults.set(data, forKey: "favorite_\(favorite.id)")
    }
    
    func getFavorites(forUserId userId: String) -> [Favorite] {
        let decoder = JSONDecoder()
        var favorites: [Favorite] = []
        
        for key in userDefaults.dictionaryRepresentation().keys {
            if key.hasPrefix("favorite_"), let data = userDefaults.data(forKey: key) {
                if let favorite = try? decoder.decode(Favorite.self, from: data) {
                    if favorite.userId == userId {
                        favorites.append(favorite)
                    }
                }
            }
        }
        
        return favorites.sorted { $0.addedAt > $1.addedAt }
    }
    
    func isFavorite(movieId: Int, userId: String) -> Bool {
        let favorites = getFavorites(forUserId: userId)
        return favorites.contains { $0.movieId == movieId }
    }
    
    func deleteFavorite(id: String) {
        userDefaults.removeObject(forKey: "favorite_\(id)")
    }
    
    func deleteFavorite(movieId: Int, userId: String) {
        let favorites = getFavorites(forUserId: userId)
        if let favorite = favorites.first(where: { $0.movieId == movieId }) {
            deleteFavorite(id: favorite.id)
        }
    }
}
