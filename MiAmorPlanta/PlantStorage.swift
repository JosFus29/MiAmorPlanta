import Foundation
import FirebaseAuth

class PlantStorage: ObservableObject {
    static let shared = PlantStorage()
    private init() {
        load()         // carga local inmediata
        listenToFirebase() // sincroniza con Firebase
    }

    private let key = "saved_plants"
    @Published var plants: [Plant] = []

    // MARK: - Carga local (UserDefaults)
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Plant].self, from: data)
        else { return }
        plants = decoded
    }

    // MARK: - Guardar local
    private func save() {
        guard let data = try? JSONEncoder().encode(plants) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: - Escuchar Firebase en tiempo real
    func listenToFirebase() {
        // Solo escucha si hay usuario autenticado
        guard Auth.auth().currentUser != nil else { return }

        FirebaseService.shared.listenToPlants { [weak self] firebasePlants in
            guard let self = self else { return }
            self.plants = firebasePlants
            self.save() // guarda localmente también
        }
    }

    // MARK: - Agregar
    func add(_ plant: Plant) {
        plants.append(plant)
        save()
        FirebaseService.shared.savePlant(plant)
    }

    // MARK: - Eliminar
    func delete(at offsets: IndexSet) {
        let plantsToDelete = offsets.map { plants[$0] }
        plants.remove(atOffsets: offsets)
        save()
        plantsToDelete.forEach { FirebaseService.shared.deletePlant($0) }
    }

    // MARK: - Actualizar
    func update(_ plant: Plant) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index] = plant
        save()
        FirebaseService.shared.savePlant(plant)
    }

    // MARK: - Contadores
    var needWaterCount: Int {
        plants.filter { $0.status == .seco }.count
    }

    var activeSensors: Int {
        plants.filter { $0.hasSensor }.count
    }

    // MARK: - Limpiar al cerrar sesión
    func clearOnLogout() {
        plants = []
        UserDefaults.standard.removeObject(forKey: key)
    }
}
