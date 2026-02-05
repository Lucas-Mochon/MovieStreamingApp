import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentSession: UserSession?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let userService = UserService()
    
    init() {
        currentSession = userService.getCurrentSession()
    }
    
    func register(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try userService.register(name: name, email: email, password: password)
            let session = try userService.login(email: email, password: password)
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
            let session = try userService.login(email: email, password: password)
            currentSession = session
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() async {
        isLoading = true
        
        do {
            try userService.logout()
            currentSession = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
