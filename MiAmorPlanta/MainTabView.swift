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
                ExplorarView()
            }
            .tabItem {
                Label("Explorar", systemImage: "magnifyingglass")
            }

            NavigationStack {
                CuidadosView()
            }
            .tabItem {
                Label("Cuidados", systemImage: "scissors")
            }

            NavigationStack {
                SensoresView()
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
