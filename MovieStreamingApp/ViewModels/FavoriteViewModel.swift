import SwiftUI
import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {

    @Published var favorites: [Favorite] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let favoriteService = FavoriteService()
    private var userId: String?

    init(userId: String? = nil) {
        self.userId = userId
        if let userId {
            loadFavorites(forUserId: userId)
        }
    }

    func loadFavorites(forUserId userId: String) {
        self.userId = userId
        errorMessage = nil
        
        do {
            favorites = try favoriteService.getFavorites(for: userId)
        } catch {
            favorites = []
            errorMessage = "Impossible de charger les favoris."
        }
    }


    func addFavorite(_ movie: Movie) {
        guard let userId else { return }
        errorMessage = nil

        do {
            if let favorite = try favoriteService.addFavorite(movie: movie, userId: userId) {
                favorites.insert(favorite, at: 0)
            }
        } catch {
            errorMessage = "Impossible d'ajouter aux favoris"
        }
    }

    func removeFavorite(movieId: Int) {
        guard let userId else { return }
        errorMessage = nil

        do {
            try favoriteService.removeFavorite(movieId: movieId, userId: userId)
            favorites.removeAll { $0.movieId == movieId }
        } catch {
            errorMessage = "Impossible de supprimer le favori"
        }
    }

    func isFavorite(movieId: Int) -> Bool {
        guard let userId else { return false }

        do {
            return try favoriteService.isFavorite(movieId: movieId, userId: userId)
        } catch {
            return false
        }
    }
}
