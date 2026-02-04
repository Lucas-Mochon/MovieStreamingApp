import SwiftUI

struct FavoritesView: View {
    @StateObject var viewModel: FavoritesViewModel
    let session: UserSession
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favorites.isEmpty {
                    VStack {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Aucun favori")
                            .foregroundColor(.gray)
                        Text("Ajoutez des films à vos favoris")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.favorites) { favorite in
                            NavigationLink(value: favorite.movie) {
                                HStack(spacing: 12) {
                                    if let posterURL = favorite.movie.posterURL {
                                        MovieImageView(url: posterURL, size: CGSize(width: 50, height: 75))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(favorite.movie.title)
                                            .font(.headline)
                                        Text(favorite.movie.displayRating)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let favorite = viewModel.favorites[index]
                                viewModel.removeFavorite(movieId: favorite.movieId, userId: favorite.userId)
                            }
                        }
                    }
                }

            }
            .navigationTitle("Mes favoris")
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie, favoritesViewModel: viewModel, session: session)
            }
        }
    }
}
