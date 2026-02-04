import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @StateObject var favoritesViewModel: FavoritesViewModel
    let session: UserSession
    @Environment(\.dismiss) var dismiss
    @State private var isFavorite = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    if let backdropURL = movie.backdropURL {
                        MovieImageView(
                            url: backdropURL,
                            size: CGSize(
                                width: geometry.size.width - 32,
                                height: 200
                            )
                        )
                        .cornerRadius(12)
                    }

                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f/10", movie.voteAverage ?? 0))
                        }

                        if let releaseDate = movie.releaseDate {
                            Text(releaseDate)
                                .foregroundColor(.gray)
                        }
                    }
                    .font(.caption)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Synopsis")
                            .font(.headline)
                        Text(movie.overview)
                            .font(.body)
                            .foregroundColor(.gray)
                    }

                    Button {
                        if isFavorite {
                            favoritesViewModel.removeFavorite(
                                movieId: movie.id,
                            )
                        } else {
                            favoritesViewModel.addFavorite(
                                movie,
                            )
                        }
                        isFavorite.toggle()
                    } label: {
                        HStack {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                            Text(isFavorite ? "Retirer des favoris" : "Ajouter aux favoris")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(isFavorite ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isFavorite = favoritesViewModel.isFavorite(movieId: movie.id)
            }
        }
    }
}
