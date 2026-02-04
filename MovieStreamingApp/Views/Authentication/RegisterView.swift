import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && password.count >= 6 && password == confirmPassword
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Créer un compte")
                    .font(.system(size: 32, weight: .bold))
                Text("Rejoignez-nous dès maintenant")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 16)
            
            VStack(spacing: 16) {
                TextField("Nom complet", text: $name)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
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
                
                SecureField("Confirmer le mot de passe", text: $confirmPassword)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                if !password.isEmpty && password.count < 6 {
                    Text("Le mot de passe doit contenir au moins 6 caractères")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Les mots de passe ne correspondent pas")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            if let error = viewModel.errorMessage {
                ErrorView(message: error)
            }
            
            Button(action: {
                Task {
                    await viewModel.register(name: name, email: email, password: password)
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("S'inscrire")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(!isFormValid || viewModel.isLoading)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Retour à la connexion")
                    .foregroundColor(.blue)
            }
        }
        .padding(24)
        .navigationBarBackButtonHidden(true)
    }
}
