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

    func loadUserFromSession() {
        guard let session = userService.getCurrentSession() else {
            errorMessage = "Aucune session active"
            isSessionExpired = true
            user = nil
            return
        }

        user = session.user
    }

    func updateProfile(name: String, email: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

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

            user = userService.getCurrentSession()?.user
            successMessage = "Profil mis à jour avec succès"

        } catch {
            errorMessage = error.localizedDescription
            loadUserFromSession()
        }

        isLoading = false
    }

    func logout() {
        userService.logout()
        user = nil
        isSessionExpired = true
    }

    private func setupSessionMonitoring() {
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
