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
        print("👤 UID del usuario: \(uid)")  // ← agrega esto
        let ruta = "Clave: usuarios/\(uid)/plantas/\(plantId)/sensor"
        ref = Database.database(url: "https://miamorplanta-default-rtdb.firebaseio.com").reference(withPath: "Clave: usuarios/PhnBJ5Mv3JcXtqHUyPFf9TWhhps2/plantas/4B207A8E-514D-4EA4-8879-8663157A5B1C/sensor")
        print("🌿 Escuchando: \(ruta)")
        iniciarLectura()
    }

    func cambiarPlanta(plantId: String) {
        guard !plantId.isEmpty else { return }
        handle.map { ref?.removeObserver(withHandle: $0) }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ruta = "usuarios/\(uid)/plantas/\(plantId)/sensor"
        ref = Database.database(url: "https://miamorplanta-default-rtdb.firebaseio.com").reference(withPath: "Clave: usuarios/PhnBJ5Mv3JcXtqHUyPFf9TWhhps2/plantas/4B207A8E-514D-4EA4-8879-8663157A5B1C/sensor")
        cargando = true
        print("🌿 Reconectando: \(ruta)")
        iniciarLectura()
    }

    func iniciarLectura() {
        Database.database(url: "https://miamorplanta-default-rtdb.firebaseio.com")
            .reference(withPath: "Clave: usuarios/PhnBJ5Mv3JcXtqHUyPFf9TWhhps2/plantas/4B207A8E-514D-4EA4-8879-8663157A5B1C/sensor")
            .observeSingleEvent(of: .value) { snap in
                print("🔥 PRUEBA DIRECTA existe: \(snap.exists())")
                print("🔥 PRUEBA DIRECTA value: \(String(describing: snap.value))")
            }

        handle = ref?.observe(.value) { snapshot in
            print("📡 Snapshot existe: \(snapshot.exists())")
            print("📡 Snapshot key: \(snapshot.key)")
            print("📡 Snapshot value: \(String(describing: snapshot.value))")
            
            guard let valores = snapshot.value as? [String: Any] else {
                print("⚠️ Sin datos en Firebase para este plantId")
                return
            }
            DispatchQueue.main.async {
                self.temperatura = (valores["temperatura"] as? Double)
                    ?? Double(valores["temperatura"] as? Int ?? 0)
                self.estadoTemperatura = valores["estado_temperatura"] as? String ?? "Sin datos"
                self.humedadCruda      = valores["humedad_cruda"]      as? Int    ?? 0
                self.estadoHumedad     = valores["estado_humedad"]     as? String ?? "Sin datos"
                self.cargando = false
            }
        } withCancel: { error in
            print("❌ Firebase RTDB cancelado: \(error.localizedDescription)")
        }
    }

    deinit {
        handle.map { ref?.removeObserver(withHandle: $0) }
    }
}
