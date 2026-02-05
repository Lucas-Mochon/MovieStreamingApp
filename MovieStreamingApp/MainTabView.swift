import SwiftUI
import Combine

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var movieViewModel = MovieViewModel()
    @StateObject private var favoritesViewModel: FavoritesViewModel
    @StateObject private var profileViewModel: ProfileViewModel

    init() {
        let authVM = AuthViewModel()
        let userService = authVM.userService
        let session = authVM.currentSession
        
        _authViewModel = StateObject(wrappedValue: authVM)
        _movieViewModel = StateObject(wrappedValue: MovieViewModel())
        _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(userId: session?.user.id))
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(userService: userService))
    }

    var body: some View {
        Group {
            if let session = authViewModel.currentSession {
                TabView {
                    MovieListView(
                        viewModel: movieViewModel,
                        favoritesViewModel: favoritesViewModel,
                        authViewModel: authViewModel,
                        session: session
                    )
                    .tabItem { Label("Films", systemImage: "film") }

                    FavoritesView(viewModel: favoritesViewModel, session: session)
                        .tabItem { Label("Favoris", systemImage: "heart.fill") }

                    ProfileView(viewModel: profileViewModel, authViewModel: authViewModel)
                        .tabItem { Label("Profil", systemImage: "person.fill") }
                }
            } else {
                AuthenticationContainer(viewModel: authViewModel)
            }
        }
        .onChange(of: authViewModel.currentSession?.token) {
            favoritesViewModel.updateUser(userId: authViewModel.currentSession?.user.id)
            profileViewModel.loadUserFromSession()
        }
    }
}
