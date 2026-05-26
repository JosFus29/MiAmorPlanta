import Foundation
import FirebaseAuth

class PlantStorage: ObservableObject {
    static let shared = PlantStorage()
    private init() {
        load() // carga local inmediata mientras llega Firebase
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
    // Llamar DESPUÉS de confirmar que hay sesión activa
    func listenToFirebase() {
        guard Auth.auth().currentUser != nil else {
            print("⚠️ listenToFirebase: sin usuario, abortando")
            return
        }

        FirebaseService.shared.listenToPlants { [weak self] firebasePlants in
            guard let self = self else { return }
            self.plants = firebasePlants
            self.save()
        }
    }

    // MARK: - Agregar
    func add(_ plant: Plant) {
        plants.append(plant)
        save()
        FirebaseService.shared.savePlant(plant)
    }

    // MARK: - Eliminar por IndexSet (usado en listas con swipe)
    func delete(at offsets: IndexSet) {
        let plantsToDelete = offsets.map { plants[$0] }
        plants.remove(atOffsets: offsets)
        save()
        plantsToDelete.forEach { FirebaseService.shared.deletePlant($0) }
    }

    // MARK: - Eliminar por Plant (usado en PlantDetailView)
    func delete(plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        save()
        FirebaseService.shared.deletePlant(plant)
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
