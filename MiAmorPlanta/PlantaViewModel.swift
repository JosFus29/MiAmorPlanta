import Foundation
import FirebaseDatabase

class PlantaViewModel: ObservableObject {
    @Published var temperatura: Double = 0.0
    @Published var estadoTemperatura: String = "Cargando..."
    @Published var humedadCruda: Int = 0
    @Published var estadoHumedad: String = "Cargando..."
    
    private var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference(withPath: "estado_planta")
        iniciarLectura()
    }
    
    func iniciarLectura() {
        ref.observe(.value) { snapshot in
            guard let valores = snapshot.value as? [String: Any] else { return }
            
            DispatchQueue.main.async {
                self.temperatura = valores["temperatura"] as? Double ?? 0.0
                self.estadoTemperatura = valores["estado_temperatura"] as? String ?? "Sin datos"
                self.humedadCruda = valores["humedad_cruda"] as? Int ?? 0
                self.estadoHumedad = valores["estado_humedad"] as? String ?? "Sin datos"
            }
        }
    }
}
