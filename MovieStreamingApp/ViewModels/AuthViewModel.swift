import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentSession: UserSession?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    init() {
        currentSession = authService.getCurrentSession()
    }
    
    func register(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try authService.register(name: name, email: email, password: password)
            let session = try authService.login(email: email, password: password)
            currentSession = session
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try authService.login(email: email, password: password)
            currentSession = session
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() async {
        isLoading = true
        
        do {
            try authService.logout()
            currentSession = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
