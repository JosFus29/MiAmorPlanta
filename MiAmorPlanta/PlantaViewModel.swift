import Foundation
import FirebaseDatabase
import FirebaseAuth

class PlantaViewModel: ObservableObject {
    @Published var temperatura: Double = 0.0
    @Published var estadoTemperatura: String = "Cargando..."
    @Published var humedadCruda: Int = 0
    @Published var estadoHumedad: String = "Cargando..."
    @Published var isConnected: Bool = false

    private var ref: DatabaseReference!
    private var handle: DatabaseHandle?
    private let plantId: String

    // plantId = el UUID de la planta en la app
    init(plantId: String) {
        self.plantId = plantId

        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No hay usuario autenticado")
            self.estadoHumedad = "Sin sesión"
            self.estadoTemperatura = "Sin sesión"
            return
        }

        // Ruta única por usuario → planta → sensor
        ref = Database.database()
            .reference()
            .child("usuarios")
            .child(userId)
            .child("plantas")
            .child(plantId)
            .child("sensor")

        iniciarLectura()
    }

    // MARK: - Escuchar datos en tiempo real
    func iniciarLectura() {
        handle = ref.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }

            guard let valores = snapshot.value as? [String: Any] else {
                DispatchQueue.main.async {
                    self.isConnected = false
                    self.estadoHumedad = "Sin datos"
                    self.estadoTemperatura = "Sin datos"
                }
                return
            }

            DispatchQueue.main.async {
                self.temperatura      = valores["temperatura"] as? Double ?? 0.0
                self.estadoTemperatura = valores["estado_temperatura"] as? String ?? "Sin datos"
                self.humedadCruda     = valores["humedad_cruda"] as? Int ?? 0
                self.estadoHumedad    = valores["estado_humedad"] as? String ?? "Sin datos"
                self.isConnected      = true
            }
        }
    }

    // MARK: - Detener escucha
    func detenerLectura() {
        if let handle = handle {
            ref?.removeObserver(withHandle: handle)
        }
    }

    deinit {
        detenerLectura()
    }
}
