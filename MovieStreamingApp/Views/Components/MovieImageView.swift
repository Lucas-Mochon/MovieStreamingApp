import SwiftUI

struct MovieImageView: View {
    let url: URL?
    let size: CGSize
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(.systemGray6)
                
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "film")
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else { return }
        
        isLoading = true
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                self.image = uiImage
            }
        } catch {
            print("Erreur chargement image: \(error)")
        }
        
        isLoading = false
    }
}
