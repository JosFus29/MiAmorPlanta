import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthService.shared

    var body: some View {
        if auth.isLoggedIn {
            MainTabView()
        } else {
            SplashView()
        }
    }
}

#Preview {
    ContentView()
}
