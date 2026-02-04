import SwiftUI
import Combine

struct MovieListContent: View {
    let movies: [Movie]
    let isLoading: Bool
    let favoritesViewModel: FavoritesViewModel
    let session: UserSession
    let loadMore: () async -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(movies) { movie in
                    NavigationLink(value: movie) {
                        MovieCard(
                            movie: movie,
                            isFavorite: favoritesViewModel.isFavorite(movieId: movie.id),
                            onFavoriteToggle: {
                                if favoritesViewModel.isFavorite(movieId: movie.id) {
                                    favoritesViewModel.removeFavorite(
                                        movieId: movie.id,
                                        userId: session.user.id
                                    )
                                } else {
                                    favoritesViewModel.addFavorite(
                                        movie,
                                        userId: session.user.id
                                    )
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if movie.id == movies.last?.id {
                            Task {
                                await loadMore()
                            }
                        }
                    }
                }

                if isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(16)
        }
    }
}
