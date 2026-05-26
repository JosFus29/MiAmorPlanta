import SwiftUI

struct ContentView: View {
    var body: some View {
        if AccountStorage.shared.hasAccount {
            MainTabView()
        } else {
            SplashView()
        }
    }
}

#Preview {
    ContentView()
}
