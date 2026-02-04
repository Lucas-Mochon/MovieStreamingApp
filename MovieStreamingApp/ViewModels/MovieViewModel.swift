import SwiftUI
import Combine

@MainActor
final class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMorePages = true
    @Published var searchQuery = ""
    @Published var selectedSort: SortOption = .popularity
    
    private let apiService = ApiService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var currentOffset = 0
    private let itemsPerPage = 20
    
    init() {
        // ✅ Debounce sur searchQuery (300ms)
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                Task { await self?.performSearch(text: query) }
            }
            .store(in: &cancellables)
    }
    
    // ✅ Charge les films populaires initialement
    func loadInitialMovies() async {
        currentPage = 1
        hasMorePages = true
        movies = []
        await loadPopularMovies()
    }
    
    // ✅ Charge plus de films (pagination)
    func loadMoreMovies() async {
        guard !isLoading && hasMorePages && searchQuery.isEmpty else { return }
        
        currentPage += 1
        await loadPopularMovies()
    }
    
    func loadPopularMovies() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.fetchPopularMovies(page: currentPage)
            if currentPage == 1 {
                movies = response.results
            } else {
                movies.append(contentsOf: response.results)
            }
            hasMorePages = currentPage < response.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadTopRatedMovies() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.fetchTopRatedMovies(page: currentPage)
            if currentPage == 1 {
                movies = response.results
            } else {
                movies.append(contentsOf: response.results)
            }
            hasMorePages = currentPage < response.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // ✅ Fonction appelée automatiquement par le debounce
    private func performSearch(text: String) async {
        if text.isEmpty {
            await loadInitialMovies()
        } else {
            await searchMovies(by: text)
        }
    }
    
    // ✅ Recherche les films par requête
    func searchMovies(by query: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.searchMovies(query: query, page: 1)
            movies = response.results
            hasMorePages = 1 < response.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // ✅ Réinitialise la recherche
    func clearSearch() {
        searchQuery = ""
    }
    
    func resetPagination() {
        currentPage = 1
        movies = []
        hasMorePages = true
    }
}
