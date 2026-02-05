import XCTest
@testable import MovieStreamingApp

final class FavoriteTests: XCTestCase {
    
    func testFavoriteInitialization() {
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 8.0,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        let favorite = Favorite(
            userId: "user123",
            movieId: 1,
            movie: movie,
            addedAt: Date()
        )
        
        XCTAssertEqual(favorite.userId, "user123")
        XCTAssertEqual(favorite.movieId, 1)
        XCTAssertEqual(favorite.movie.id, 1)
    }
    
    func testFavoriteUUID() {
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 8.0,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        let favorite1 = Favorite(
            userId: "user123",
            movieId: 1,
            movie: movie,
            addedAt: Date()
        )
        
        let favorite2 = Favorite(
            userId: "user123",
            movieId: 1,
            movie: movie,
            addedAt: Date()
        )
        
        XCTAssertNotEqual(favorite1.id, favorite2.id)
    }
}
