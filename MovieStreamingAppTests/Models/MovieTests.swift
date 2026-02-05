import XCTest
@testable import MovieStreamingApp

final class MovieTests: XCTestCase {
    
    func testMovieInitialization() {
        let movie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test overview",
            posterPath: "/test.jpg",
            backdropPath: "/backdrop.jpg",
            voteAverage: 8.5,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.voteAverage, 8.5)
    }
    
    func testPosterURL() {
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: "/test.jpg",
            backdropPath: nil,
            voteAverage: 8.0,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        let expectedURL = URL(string: "https://image.tmdb.org/t/p/w500/test.jpg")
        XCTAssertEqual(movie.posterURL, expectedURL)
    }
    
    func testPosterURLNil() {
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
        
        XCTAssertNil(movie.posterURL)
    }
    
    func testBackdropURL() {
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: "/backdrop.jpg",
            voteAverage: 8.0,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        let expectedURL = URL(string: "https://image.tmdb.org/t/p/w1280/backdrop.jpg")
        XCTAssertEqual(movie.backdropURL, expectedURL)
    }
    
    func testDisplayRating() {
        let movieWithRating = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 8.567,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        XCTAssertEqual(movieWithRating.displayRating, "8.6")
    }
    
    func testDisplayRatingNil() {
        let movieWithoutRating = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: nil,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        XCTAssertEqual(movieWithoutRating.displayRating, "N/A")
    }
    
    func testMovieHashable() {
        let movie1 = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 8.0,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        let movie2 = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 8.0,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        XCTAssertEqual(movie1, movie2)
    }
    
    func testMovieCodable() throws {
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: "/test.jpg",
            backdropPath: nil,
            voteAverage: 8.0,
            releaseDate: "2024-01-01",
            popularity: 100.0
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(movie)
        
        let decoder = JSONDecoder()
        let decodedMovie = try decoder.decode(Movie.self, from: data)
        
        XCTAssertEqual(movie, decodedMovie)
    }
}
