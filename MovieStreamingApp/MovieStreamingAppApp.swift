import SwiftUI

@main
struct MovieStreamingApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(nil)
        }
    }
}
