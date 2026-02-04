import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .invalidResponse(let code):
            return "Erreur serveur: \(code)"
        case .decodingError:
            return "Erreur de décodage des données"
        case .networkError:
            return "Erreur réseau"
        case .unauthorized:
            return "Non autorisé"
        case .notFound:
            return "Ressource non trouvée"
        case .serverError:
            return "Erreur serveur"
        case .unknown:
            return "Erreur inconnue"
        }
    }
}
