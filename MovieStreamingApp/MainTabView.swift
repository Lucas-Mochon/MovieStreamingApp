import SwiftUI
import Combine

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var movieViewModel = MovieViewModel()
    @StateObject private var favoritesViewModel: FavoritesViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    
    init() {
        let authVM = AuthViewModel()
        _authViewModel = StateObject(wrappedValue: authVM)
        _movieViewModel = StateObject(wrappedValue: MovieViewModel())
        
        if let userId = authVM.currentSession?.user.id {
            _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(userId: userId))
            _profileViewModel = StateObject(wrappedValue: ProfileViewModel(user: authVM.currentSession?.user))
        } else {
            _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel())
            _profileViewModel = StateObject(wrappedValue: ProfileViewModel())
        }
    }
    
    var body: some View {
        if let session = authViewModel.currentSession {
            TabView {
                MovieListView(viewModel: movieViewModel, favoritesViewModel: favoritesViewModel)
                    .tabItem {
                        Label("Films", systemImage: "film")
                    }
                
                FavoritesView(viewModel: favoritesViewModel)
                    .tabItem {
                        Label("Favoris", systemImage: "heart.fill")
                    }
                
                ProfileView(viewModel: profileViewModel, authViewModel: authViewModel)
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
            }
        } else {
            AuthenticationContainer(viewModel: authViewModel)
        }
    }
}
