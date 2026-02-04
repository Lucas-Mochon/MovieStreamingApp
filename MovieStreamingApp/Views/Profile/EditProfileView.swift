import SwiftUI

struct EditProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var name = ""
    @State private var email = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                TextField("Nom", text: $name)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            if let success = viewModel.successMessage {
                Text(success)
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            if let error = viewModel.errorMessage {
                ErrorView(message: error)
            }
            
            Button(action: {
                Task {
                    await viewModel.updateProfile(name: name, email: email)
                    dismiss()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Enregistrer")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(viewModel.isLoading || name.isEmpty || email.isEmpty)
            
            Spacer()
        }
        .padding(16)
        .navigationTitle("Modifier le profil")
        .onAppear {
            name = viewModel.user?.name ?? ""
            email = viewModel.user?.email ?? ""
        }
    }
}
