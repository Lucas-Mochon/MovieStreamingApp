import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let authService = AuthService.shared
    private let persistence = PersistenceService.shared
    
    init(user: User? = nil) {
        self.user = user ?? authService.getCurrentSession()?.user
    }
    
    func updateProfile(name: String, email: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        guard var currentUser = user else {
            errorMessage = "Utilisateur non trouvé"
            isLoading = false
            return
        }
        
        currentUser.name = name
        currentUser.email = email
        currentUser.updatedAt = Date()
        
        do {
            try authService.updateUser(currentUser)
            user = currentUser
            successMessage = "Profil mis à jour avec succès"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
