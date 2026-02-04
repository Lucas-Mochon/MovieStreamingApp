import Foundation

struct Favorite: Codable, Identifiable {
    let id: String
    let userId: String
    let movieId: Int
    let movie: Movie
    let addedAt: Date
    
    init(userId: String, movie: Movie) {
        self.id = UUID().uuidString
        self.userId = userId
        self.movieId = movie.id
        self.movie = movie
        self.addedAt = Date()
    }
}
