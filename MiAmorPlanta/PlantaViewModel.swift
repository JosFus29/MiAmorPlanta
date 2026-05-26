import Foundation
import FirebaseDatabase
import FirebaseAuth

class PlantaViewModel: ObservableObject {
    @Published var temperatura: Double = 0.0
    @Published var estadoTemperatura: String = "Sin datos"
    @Published var humedadCruda: Int = 0
    @Published var estadoHumedad: String = "Sin datos"
    @Published var cargando: Bool = true

    private var ref: DatabaseReference?
    private var handle: DatabaseHandle?

    init(plantId: String? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("⚠️ PlantaViewModel: no hay usuario autenticado")
            cargando = false
            return
        }

        let id = plantId
            ?? PlantStorage.shared.plants.first(where: { $0.hasSensor })?.id.uuidString
            ?? ""

        guard !id.isEmpty else {
            print("⚠️ PlantaViewModel: no se encontró planta con sensor")
            cargando = false
            return
        }

        print("🌿 Escuchando: usuarios/\(uid)/plantas/\(id)/sensor")
        ref = Database.database().reference(withPath: "usuarios/\(uid)/plantas/\(id)/sensor")
        iniciarLectura()
    }

    func iniciarLectura() {
        guard let ref = ref else { return }
        handle = ref.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            guard let valores = snapshot.value as? [String: Any] else {
                DispatchQueue.main.async { self.cargando = false }
                return
            }
            DispatchQueue.main.async {
                self.temperatura       = valores["temperatura"]        as? Double ?? 0.0
                self.estadoTemperatura = valores["estado_temperatura"] as? String ?? "Sin datos"
                self.humedadCruda      = valores["humedad_cruda"]      as? Int    ?? 0
                self.estadoHumedad     = valores["estado_humedad"]     as? String ?? "Sin datos"
                self.cargando          = false
            }
        }
    }

    deinit {
        if let handle = handle { ref?.removeObserver(withHandle: handle) }
    }
}
