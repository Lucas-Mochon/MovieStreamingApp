import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Bienvenue")
                        .font(.system(size: 32, weight: .bold))
                    Text("Connectez-vous à votre compte")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    HStack {
                        if showPassword {
                            TextField("Mot de passe", text: $password)
                        } else {
                            SecureField("Mot de passe", text: $password)
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                if let error = viewModel.errorMessage {
                    ErrorView(message: error)
                }
                
                Button(action: {
                    Task {
                        await viewModel.login(email: email, password: password)
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Se connecter")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty)
                
                Spacer()
                
                HStack {
                    Text("Pas de compte ?")
                    NavigationLink("S'inscrire", destination: RegisterView(viewModel: viewModel))
                        .foregroundColor(.blue)
                }
            }
            .padding(24)
        }
    }
}
