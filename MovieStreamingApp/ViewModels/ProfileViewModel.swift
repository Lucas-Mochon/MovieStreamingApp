import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isSessionExpired = false

    private let userService: UserService
    private var cancellables = Set<AnyCancellable>()

    init(userService: UserService) {
        self.userService = userService
        loadUserFromSession()
        setupSessionMonitoring()
    }

    // MARK: - Load User

    private func loadUserFromSession() {
        guard let session = userService.getCurrentSession() else {
            errorMessage = "Aucune session active"
            isSessionExpired = true
            user = nil
            return
        }

        user = session.user
    }

    // MARK: - Update Profile

    func updateProfile(name: String, email: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        // Vérifier session valide
        guard userService.isSessionValid() else {
            errorMessage = "Session expirée, reconnexion requise"
            isSessionExpired = true
            isLoading = false
            return
        }

        guard var currentUser = user else {
            errorMessage = "Utilisateur non trouvé"
            isLoading = false
            return
        }

        // Validation basique
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty else {
            errorMessage = "Nom et email requis"
            isLoading = false
            return
        }

        currentUser.name = trimmedName
        currentUser.email = trimmedEmail
        currentUser.updatedAt = Date()

        do {
            try userService.update(user: currentUser)

            // Rafraîchir depuis la session
            user = userService.getCurrentSession()?.user
            successMessage = "Profil mis à jour avec succès"

        } catch {
            errorMessage = error.localizedDescription
            // Restaurer l'ancien user en cas d'erreur
            loadUserFromSession()
        }

        isLoading = false
    }

    // MARK: - Logout

    func logout() {
        userService.logout()
        user = nil
        isSessionExpired = true
    }

    // MARK: - Session Monitoring

    private func setupSessionMonitoring() {
        // Monitorer les changements de session toutes les 60 secondes
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkSessionValidity()
            }
            .store(in: &cancellables)
    }

    private func checkSessionValidity() {
        if !userService.isSessionValid() {
            isSessionExpired = true
            user = nil
        }
    }
}
