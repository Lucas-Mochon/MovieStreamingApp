import SwiftUI

struct AuthenticationContainer: View {
    @StateObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            LoginView(viewModel: viewModel)
        }
    }
}
