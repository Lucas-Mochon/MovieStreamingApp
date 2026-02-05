import Foundation

@MainActor
final class ApiService {
    static let shared = ApiService()
    private init() {}
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    func fetchMovies(
        page: Int = 1,
        sort: SortOption
    ) async throws -> MovieResponse {
        try await fetchMovies(
            endpoint: .discoverMovies(page: page, sort: sort)
        )
    }
    
    func fetchMovies(endpoint: TMDBEndpoint) async throws -> MovieResponse {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse(statusCode: -1)
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                do {
                    return try decoder.decode(MovieResponse.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            case 500..<600:
                throw APIError.serverError
            default:
                throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
            }
        } catch {
            if error is APIError {
                throw error
            }
            throw APIError.networkError(error)
        }
    }
    
    func searchMovies(query: String, page: Int = 1) async throws -> MovieResponse {
        try await fetchMovies(endpoint: .searchMovies(query: query, page: page))
    }
    
    func fetchUpcomingMovies(page: Int = 1) async throws -> MovieResponse {
        try await fetchMovies(endpoint: .upcomingMovies(page: page))
    }
    
    func fetchTopRatedMovies(page: Int = 1) async throws -> MovieResponse {
        try await fetchMovies(endpoint: .topRatedMovies(page: page))
    }
}
