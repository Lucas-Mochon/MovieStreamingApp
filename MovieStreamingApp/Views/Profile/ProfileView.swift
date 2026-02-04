import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @StateObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationStack {
            if let user = viewModel.user {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(user.name.prefix(1)))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(spacing: 4) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: EditProfileView(viewModel: viewModel)) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Modifier le profil")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            Task {
                                await authViewModel.logout()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle")
                                Text("Se déconnecter")
                                Spacer()
                            }
                            .foregroundColor(.red)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
                .padding(16)
                .navigationTitle("Profil")
            }
        }
    }
}
