import Foundation

struct Favorite: Codable, Identifiable {
    let id: String
    let userId: String
    let movieId: Int
    let movie: Movie
    let addedAt: Date
    
    init(id: String = UUID().uuidString, userId: String, movieId: Int, movie: Movie, addedAt: Date) {
        self.id = id
        self.userId = userId
        self.movieId = movieId
        self.movie = movie
        self.addedAt = addedAt
    }
}
