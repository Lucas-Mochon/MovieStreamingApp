struct SortOption: Hashable, CaseIterable {
    let field: SortField
    let order: SortOrder

    var displayName: String {
        "\(field.rawValue) \(order == .ascending ? "↑" : "↓")"
    }

    var apiValue: String {
        switch field {
        case .popularity: return "popularity.\(order.rawValue)"
        case .rating: return "vote_average.\(order.rawValue)"
        case .releaseDate: return "release_date.\(order.rawValue)"
        case .title: return "original_title.\(order.rawValue)"
        }
    }

    static var allCases: [SortOption] {
        SortField.allCases.flatMap { field in
            SortOrder.allCases.map { order in
                SortOption(field: field, order: order)
            }
        }
    }
}
