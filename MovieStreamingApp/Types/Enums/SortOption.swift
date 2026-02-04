import Foundation

enum SortOption: String, CaseIterable {
    case popularity = "Popularité"
    case rating = "Note"
    case releaseDate = "Date de sortie"
    case title = "Titre"
    
    var apiValue: String {
        switch self {
        case .popularity:
            return "popularity.desc"
        case .rating:
            return "vote_average.desc"
        case .releaseDate:
            return "release_date.desc"
        case .title:
            return "original_title.asc"
        }
    }
}
