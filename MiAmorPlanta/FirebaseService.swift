import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()

    // MARK: - UID del usuario actual
    var userId: String {
        Auth.auth().currentUser?.uid ?? "anonimo"
    }

    // MARK: - Guardar perfil al registrarse
    func saveProfile(name: String, email: String) {
        db.collection("usuarios")
            .document(userId)
            .setData([
                "nombre": name,
                "email": email,
                "fechaRegistro": Timestamp()
            ], merge: true)
    }

    // MARK: - Guardar planta
    func savePlant(_ plant: Plant) {
        let data: [String: Any] = [
            "id": plant.id.uuidString,
            "name": plant.name,
            "emoji": plant.emoji,
            "location": plant.location,
            "status": plant.status.rawValue,
            "hasSensor": plant.hasSensor,
            "daysUntilWatering": plant.daysUntilWatering,
            "fertilizingFrequency": plant.fertilizingFrequency,
            "cleaningFrequency": plant.cleaningFrequency
        ]

        db.collection("usuarios")
            .document(userId)
            .collection("plantas")
            .document(plant.id.uuidString)
            .setData(data) { error in
                if let error = error {
                    print("❌ Error guardando planta: \(error.localizedDescription)")
                } else {
                    print("✅ Planta guardada en Firebase")
                }
            }
    }

    // MARK: - Eliminar planta
    func deletePlant(_ plant: Plant) {
        db.collection("usuarios")
            .document(userId)
            .collection("plantas")
            .document(plant.id.uuidString)
            .delete { error in
                if let error = error {
                    print("❌ Error eliminando planta: \(error.localizedDescription)")
                } else {
                    print("✅ Planta eliminada de Firebase")
                }
            }
    }

    // MARK: - Escuchar plantas en tiempo real
    func listenToPlants(completion: @escaping ([Plant]) -> Void) {
        db.collection("usuarios")
            .document(userId)
            .collection("plantas")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("❌ Error escuchando plantas: \(error?.localizedDescription ?? "")")
                    return
                }

                let plants: [Plant] = documents.compactMap { doc -> Plant? in
                    let data = doc.data()
                    guard
                        let idString = data["id"] as? String,
                        let id = UUID(uuidString: idString),
                        let name = data["name"] as? String,
                        let emoji = data["emoji"] as? String,
                        let location = data["location"] as? String,
                        let statusRaw = data["status"] as? String,
                        let status = PlantStatus(rawValue: statusRaw),
                        let hasSensor = data["hasSensor"] as? Bool,
                        let days = data["daysUntilWatering"] as? Int
                    else { return nil }

                    return Plant(
                        id: id,
                        name: name,
                        location: location,
                        status: status,
                        hasSensor: hasSensor,
                        emoji: emoji,
                        fertilizingFrequency: data["fertilizingFrequency"] as? String ?? "",
                        cleaningFrequency: data["cleaningFrequency"] as? String ?? "",
                        daysUntilWatering: days
                    )
                }

                DispatchQueue.main.async {
                    completion(plants)
                }
            }
    }
}
