import Foundation

final class FavoriteService {

    private let dao: FavoriteDAO

    init(dao: FavoriteDAO = FavoriteDAO()) {
        self.dao = dao
    }

    func getFavorites(for userId: String) throws -> [Favorite] {
        try dao.findAllByUserId(userId)
    }

    func addFavorite(movie: Movie, userId: String) throws -> Favorite? {
        if try dao.exists(userId: userId, movieId: movie.id) {
            return nil
        }

        let favorite = Favorite(userId: userId, movieId: movie.id, movie: movie, addedAt: Date())
        return try dao.insert(favorite)
    }

    func removeFavorite(movieId: Int, userId: String) throws {
        try dao.delete(userId: userId, movieId: movieId)
    }

    func isFavorite(movieId: Int, userId: String) throws -> Bool {
        try dao.exists(userId: userId, movieId: movieId)
    }
}

