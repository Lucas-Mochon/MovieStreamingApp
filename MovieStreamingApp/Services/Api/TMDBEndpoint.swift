import Foundation

enum TMDBEndpoint {
    case discoverMovies(page: Int, sort: SortOption, releaseDateLTE: String? = nil)
    case searchMovies(query: String, page: Int)
    case movieDetails(id: Int)
    case upcomingMovies(page: Int)
    case topRatedMovies(page: Int)
    
    private var baseURL: String {
        "https://api.themoviedb.org/3"
    }
    
    private var apiKey: String {
        print(Secrets.tmdbApiKey)
       return Secrets.tmdbApiKey
    }
    
    var path: String {
        switch self {
        case .discoverMovies:
            return "/discover/movie"
        case .searchMovies:
            return "/search/movie"
        case .movieDetails(let id):
            return "/movie/\(id)"
        case .upcomingMovies:
            return "/movie/upcoming"
        case .topRatedMovies:
            return "/movie/top_rated"
        }
    }
    
    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "fr-FR")
        ]
        
        switch self {
        case .discoverMovies(let page, let sort, let releaseDateLTE):
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "sort_by", value: sort.apiValue))
            if let lte = releaseDateLTE {
                items.append(URLQueryItem(name: "release_date.lte", value: lte))
            }
            
        case .searchMovies(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: String(page)))
            
        case .upcomingMovies(let page),
             .topRatedMovies(let page):
            items.append(URLQueryItem(name: "page", value: String(page)))
            
        default:
            break
        }
        
        return items
    }
    
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}

struct Secrets {
    static var tmdbApiKey: String {
        guard let key = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String else {
            fatalError("TMDB_API_KEY not set in Info.plist or xcconfig!")
        }
        return key
    }
}
