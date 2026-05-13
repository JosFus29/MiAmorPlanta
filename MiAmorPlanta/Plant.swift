import Foundation

struct Plant: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var location: String
    var status: PlantStatus
    var hasSensor: Bool
    var emoji: String

    // Datos de sensor (solo si hasSensor == true)
    var temperature: Double = 22.0
    var humidity: Int = 18
    var light: LightLevel = .media

    // Cuidados programados
    var wateringDays: [WateringDay] = [.lun, .mier, .vie]
    var fertilizingFrequency: String = "Cada 15 días"
    var cleaningFrequency: String = "Semanal"
    var daysUntilWatering: Int = 3
}

enum PlantStatus: String, Codable, CaseIterable {
    case bien   = "Bien"
    case seco   = "Seco"
    case pronto = "Pronto"

    var color: String {
        switch self {
        case .bien:   return "StatusGreen"
        case .seco:   return "StatusRed"
        case .pronto: return "StatusBlue"
        }
    }

    var icon: String {
        switch self {
        case .bien:   return "checkmark.circle.fill"
        case .seco:   return "exclamationmark.circle.fill"
        case .pronto: return "clock.fill"
        }
    }
}

enum LightLevel: String, Codable, CaseIterable {
    case baja  = "Baja"
    case media = "Media"
    case alta  = "Alta"

    var icon: String { "sun.max.fill" }
}

enum WateringDay: String, Codable, CaseIterable {
    case lun = "Lun"
    case mar = "Mar"
    case mier = "Mier"
    case jue = "Jue"
    case vie = "Vie"
    case sab = "Sáb"
    case dom = "Dom"
}
