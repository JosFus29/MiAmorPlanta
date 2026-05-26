import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }

            NavigationStack {
                CuidadosView()
            }
            .tabItem {
                Label("Cuidados", systemImage: "scissors")
            }

            NavigationStack {
                SensoresView()  // ← nueva pestaña
            }
            .tabItem {
                Label("Sensores", systemImage: "antenna.radiowaves.left.and.right")
            }

            NavigationStack {
                AlertasView()
            }
            .tabItem {
                Label("Alertas", systemImage: "bell.fill")
            }

            NavigationStack {
                ConfigView()
            }
            .tabItem {
                Label("Config", systemImage: "gearshape.fill")
            }
        }
        .tint(Color("PlantDark"))
    }
}

#Preview {
    MainTabView()
}
