import SwiftUI
import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let persistence = PersistenceService.shared
    private var userId: String?
    
    init(userId: String? = nil) {
        self.userId = userId
        if let userId = userId {
            loadFavorites(forUserId: userId)
        }
    }
    
    func loadFavorites(forUserId userId: String) {
        self.userId = userId
        favorites = persistence.getFavorites(forUserId: userId)
    }
    
    func addFavorite(_ movie: Movie, userId: String) {
        let favorite = Favorite(userId: userId, movie: movie)
        do {
            try persistence.saveFavorite(favorite)
            favorites.append(favorite)
            favorites.sort { $0.addedAt > $1.addedAt }
        } catch {
            errorMessage = "Impossible d'ajouter aux favoris"
        }
    }
    
    func removeFavorite(movieId: Int, userId: String) {
        persistence.deleteFavorite(movieId: movieId, userId: userId)
        favorites.removeAll { $0.movieId == movieId }
    }
    
    func isFavorite(movieId: Int) -> Bool {
        guard let userId = userId else { return false }
        return persistence.isFavorite(movieId: movieId, userId: userId)
    }
}
