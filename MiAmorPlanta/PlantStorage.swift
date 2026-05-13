import Foundation

class PlantStorage: ObservableObject {

    static let shared = PlantStorage()
    private init() { load() }

    private let key = "saved_plants"

    @Published var plants: [Plant] = []

    // MARK: - Cargar

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Plant].self, from: data)
        else { return }
        plants = decoded
    }

    // MARK: - Guardar

    private func save() {
        guard let data = try? JSONEncoder().encode(plants) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: - Agregar

    func add(_ plant: Plant) {
        plants.append(plant)
        save()
    }

    // MARK: - Eliminar

    func delete(at offsets: IndexSet) {
        plants.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Contadores

    var needWaterCount: Int {
        plants.filter { $0.status == .seco }.count
    }

    var activeSensors: Int {
        plants.filter { $0.hasSensor }.count
    }
    // MARK: - Actualizar

    func update(_ plant: Plant) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index] = plant
        save()
    }
}
