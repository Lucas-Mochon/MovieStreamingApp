import SwiftUI
import Combine

struct MovieListView: View {
    @ObservedObject var viewModel: MovieViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @ObservedObject var authViewModel: AuthViewModel
    let session: UserSession

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SearchBar(text: $viewModel.searchQuery)
                
                HStack(spacing: 16) {
                    Picker("Champ", selection: $viewModel.selectedSortField) {
                        ForEach(SortField.allCases, id: \.self) { field in
                            Text(field.rawValue).tag(field)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("", selection: $viewModel.selectedSortOrder) {
                        Image(systemName: "arrow.up").tag(SortOrder.ascending)
                        Image(systemName: "arrow.down").tag(SortOrder.descending)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                }
                .padding(.horizontal)
                
                content
            }
            .navigationTitle("Films")
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie, favoritesViewModel: favoritesViewModel, session: session)
            }
            .task { await viewModel.loadInitialMovies() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.movies.isEmpty { LoadingView() }
        else if let error = viewModel.errorMessage { ErrorView(message: error) }
        else if viewModel.movies.isEmpty { EmptyStateView() }
        else {
            MovieListContent(
                movies: viewModel.movies,
                isLoading: viewModel.isLoading,
                favoritesViewModel: favoritesViewModel,
                session: session,
                loadMore: { await viewModel.loadMoreMovies() }
            )
        }
    }
}
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Rechercher un film...", text: $text)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(16)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Aucun film trouvé")
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
}
