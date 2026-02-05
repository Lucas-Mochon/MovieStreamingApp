import XCTest
@testable import MovieStreamingApp

final class MovieResponseTests: XCTestCase {
    
    func testMovieResponseCodable() throws {
        let json = """
        {
            "results": [
                {
                    "id": 1,
                    "title": "Test Movie",
                    "overview": "Test",
                    "poster_path": "/test.jpg",
                    "backdrop_path": null,
                    "vote_average": 8.0,
                    "release_date": "2024-01-01",
                    "popularity": 100.0
                }
            ],
            "page": 1,
            "total_pages": 10,
            "total_results": 100
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(MovieResponse.self, from: data)
        
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 10)
        XCTAssertEqual(response.totalResults, 100)
        XCTAssertEqual(response.results.count, 1)
    }
}
