import Foundation
import FirebaseDatabase
import FirebaseAuth

class PlantaViewModel: ObservableObject {
    @Published var temperatura: Double = 0.0
    @Published var estadoTemperatura: String = "Cargando..."
    @Published var humedadCruda: Int = 0
    @Published var estadoHumedad: String = "Cargando..."
    @Published var cargando: Bool = true

    private var ref: DatabaseReference?
    private var handle: DatabaseHandle?

    init(plantId: String) {
        guard !plantId.isEmpty else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ PlantaViewModel: no hay usuario logueado")
            return
        }
        let ruta = "usuarios/\(uid)/plantas/\(plantId)/sensor"
        ref = Database.database().reference(withPath: ruta)
        print("🌿 Escuchando: \(ruta)")
        iniciarLectura()
    }

    func cambiarPlanta(plantId: String) {
        guard !plantId.isEmpty else { return }
        handle.map { ref?.removeObserver(withHandle: $0) }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ruta = "usuarios/\(uid)/plantas/\(plantId)/sensor"
        ref = Database.database().reference(withPath: ruta)
        cargando = true
        print("🌿 Reconectando: \(ruta)")
        iniciarLectura()
    }

    func iniciarLectura() {
        handle = ref?.observe(.value) { snapshot in
            guard let valores = snapshot.value as? [String: Any] else {
                print("⚠️ Sin datos en Firebase para este plantId")
                return
            }
            DispatchQueue.main.async {
                self.temperatura       = valores["temperatura"]        as? Double ?? 0.0
                self.estadoTemperatura = valores["estado_temperatura"] as? String ?? "Sin datos"
                self.humedadCruda      = valores["humedad_cruda"]      as? Int    ?? 0
                self.estadoHumedad     = valores["estado_humedad"]     as? String ?? "Sin datos"
                self.cargando = false
            }
        }
    }

    deinit {
        handle.map { ref?.removeObserver(withHandle: $0) }
    }
}
