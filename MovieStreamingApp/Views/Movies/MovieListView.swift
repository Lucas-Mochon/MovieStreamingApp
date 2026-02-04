import SwiftUI

struct MovieListView: View {
    @StateObject var viewModel: MovieViewModel
    @StateObject var favoritesViewModel: FavoritesViewModel
    @State private var selectedMovie: Movie?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SearchBar(text: $viewModel.searchQuery)
                
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error)
                } else if viewModel.movies.isEmpty {
                    VStack {
                        Image(systemName: "film")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Aucun film trouvé")
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink(value: movie) {
                                    MovieCard(
                                        movie: movie,
                                        isFavorite: favoritesViewModel.isFavorite(movieId: movie.id)
                                    )
                                }
                                .onAppear {
                                    if movie.id == viewModel.movies.last?.id {
                                        Task {
                                            await viewModel.loadMoreMovies()
                                        }
                                    }
                                }
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Films")
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie, favoritesViewModel: favoritesViewModel)
            }
            .task {
                await viewModel.loadInitialMovies()
            }
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
