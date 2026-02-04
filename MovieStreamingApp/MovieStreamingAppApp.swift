import SwiftUI

@main
struct MovieStreamingApp: App {
    init() {
        _ = DatabaseManager.shared
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(nil)
        }
    }
}
