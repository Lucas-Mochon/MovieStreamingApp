import SwiftUI
import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {

    @Published private(set) var favorites: [Favorite] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let favoriteService = FavoriteService()
    
    // L'utilisateur courant
    private var userId: String? {
        didSet {
            // Recharge automatiquement les favoris quand l'user change
            loadFavorites()
        }
    }

    init(userId: String? = nil) {
        self.userId = userId
        loadFavorites()
    }

    // MARK: - Mettre à jour l'utilisateur
    func updateUser(userId: String?) {
        self.userId = userId
    }

    // MARK: - Charger les favoris
    func loadFavorites() {
        guard let userId = userId else {
            favorites = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            favorites = try favoriteService.getFavorites(for: userId)
        } catch {
            favorites = []
            errorMessage = "Impossible de charger les favoris : \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Ajouter un favori
    func addFavorite(_ movie: Movie) {
        guard let userId = userId else { return }
        errorMessage = nil

        do {
            if let favorite = try favoriteService.addFavorite(movie: movie, userId: userId) {
                favorites.insert(favorite, at: 0)
            }
        } catch {
            errorMessage = "Impossible d'ajouter aux favoris : \(error.localizedDescription)"
        }
    }

    // MARK: - Supprimer un favori
    func removeFavorite(movieId: Int) {
        guard let userId = userId else { return }
        errorMessage = nil

        do {
            try favoriteService.removeFavorite(movieId: movieId, userId: userId)
            favorites.removeAll { $0.movieId == movieId }
        } catch {
            errorMessage = "Impossible de supprimer le favori : \(error.localizedDescription)"
        }
    }

    // MARK: - Vérifier si c'est un favori
    func isFavorite(movieId: Int) -> Bool {
        guard let userId = userId else { return false }

        do {
            return try favoriteService.isFavorite(movieId: movieId, userId: userId)
        } catch {
            return false
        }
    }
}
