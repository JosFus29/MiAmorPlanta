import SwiftUI
import FirebaseDatabase
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // ── Prueba raíz RTDB ──
        Database.database(url: "https://miamorplanta-default-rtdb.firebaseio.com")
            .reference()
            .observeSingleEvent(of: .value) { snap in
                print("🔥 RAÍZ existe: \(snap.exists())")
                print("🔥 RAÍZ childrenCount: \(snap.childrenCount)")
                print("🔥 RAÍZ value: \(String(describing: snap.value))")
            }
        // ─────────────────────
        
        return true
    }
}

@main
struct MiAmorPlantaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
