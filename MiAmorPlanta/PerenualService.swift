import Foundation

// MARK: - Modelo de detalle de planta (API Perenual) — campos completos

struct PerenualPlantDetail: Codable {
    let id: Int
    let common_name: String?
    let scientific_name: [String]?
    let other_name: [String]?
    let family: String?
    let description: String?
    let type: String?
    let cycle: String?
    let watering: String?
    let sunlight: [String]?
    let growth_rate: String?
    let maintenance: String?
    let care_level: String?
    let drought_tolerant: IntOrBool?
    let salt_tolerant: IntOrBool?
    let thorny: IntOrBool?
    let invasive: IntOrBool?
    let tropical: IntOrBool?
    let indoor: IntOrBool?
    let flowers: IntOrBool?
    let flowering_season: String?
    let fruits: IntOrBool?
    let edible_fruit: IntOrBool?
    let harvest_season: String?
    let leaf: IntOrBool?
    let edible_leaf: IntOrBool?
    let medicinal: IntOrBool?
    let poisonous_to_humans: IntOrBool?
    let poisonous_to_pets: IntOrBool?
    let cuisine: IntOrBool?
    let soil: [String]?
    let pest_susceptibility: [String]?
    let attracts: [String]?
    let propagation: [String]?
    let pruning_month: [String]?
    let pruning_count: PruningCount?
    let origin: [String]?
    let hardiness: Hardiness?
    let watering_general_benchmark: WateringBenchmark?
    let dimensions: [PlantDimension]?
    let plant_anatomy: [PlantAnatomy]?
    let default_image: PerenualImage?
    let care_guides: String?

    // other_images excluido del decoder — el API manda string o array indistintamente
    enum CodingKeys: String, CodingKey {
        case id, common_name, scientific_name, other_name, family, description
        case type, cycle, watering, sunlight, growth_rate, maintenance, care_level
        case drought_tolerant, salt_tolerant, thorny, invasive, tropical, indoor
        case flowers, flowering_season, fruits, edible_fruit, harvest_season
        case leaf, edible_leaf, medicinal, poisonous_to_humans, poisonous_to_pets
        case cuisine, soil, pest_susceptibility, attracts, propagation
        case pruning_month, pruning_count, origin, hardiness
        case watering_general_benchmark, dimensions, plant_anatomy
        case default_image, care_guides
    }

    var displayName: String {
        if let name = common_name, !name.isEmpty { return name.capitalized }
        if let sci = scientific_name?.first, !sci.isEmpty { return sci }
        return "Planta"
    }

    var sciName: String { scientific_name?.first ?? "" }

    var imageURL: URL? {
        if let str = default_image?.medium_url ?? default_image?.regular_url ?? default_image?.original_url {
            return URL(string: str)
        }
        return nil
    }
}

// MARK: - IntOrBool — Perenual a veces manda 0/1 y a veces true/false

enum IntOrBool: Codable {
    case int(Int)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let b = try? c.decode(Bool.self) { self = .bool(b); return }
        if let i = try? c.decode(Int.self)  { self = .int(i);  return }
        self = .bool(false)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .bool(let b): try c.encode(b)
        case .int(let i):  try c.encode(i)
        }
    }

    var isTrue: Bool {
        switch self {
        case .bool(let b): return b
        case .int(let i):  return i != 0
        }
    }
}

// MARK: - Structs de soporte

struct PruningCount: Codable {
    let amount: Int?
    let interval: String?

    init(from decoder: Decoder) throws {
        // El API a veces manda [] en vez de {} — lo manejamos
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            amount = try? container.decodeIfPresent(Int.self, forKey: .amount)
            interval = try? container.decodeIfPresent(String.self, forKey: .interval)
        } else {
            amount = nil
            interval = nil
        }
    }
}

struct Hardiness: Codable {
    let min: String?
    let max: String?
}

struct WateringBenchmark: Codable {
    let value: String?
    let unit: String?
}

struct PlantDimension: Codable {
    let type: String?
    let min_value: Double?
    let max_value: Double?
    let unit: String?
}

struct PlantAnatomy: Codable {
    let part: String?
    let color: [String]?
}

struct PerenualImage: Codable, Hashable, Equatable {
    let original_url: String?
    let regular_url: String?
    let medium_url: String?
    let small_url: String?
    let thumbnail: String?
}

// MARK: - Respuesta de búsqueda

struct PerenualSearchResponse: Codable {
    let data: [PerenualSearchItem]
    let to: Int?
    let per_page: Int?
    let current_page: Int?
    let last_page: Int?
}

struct PerenualSearchItem: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let common_name: String?
    let scientific_name: [String]?
    let cycle: String?
    let watering: String?
    let sunlight: [String]?
    let default_image: PerenualImage?

    var displayName: String {
        if let name = common_name, !name.isEmpty { return name.capitalized }
        if let sci = scientific_name?.first { return sci }
        return "Planta"
    }

    var imageURL: URL? {
        if let str = default_image?.medium_url ?? default_image?.thumbnail {
            return URL(string: str)
        }
        return nil
    }
}

// MARK: - Servicio Perenual

class PerenualService {
    static let shared = PerenualService()
    private init() {}

    private let apiKey = "sk-XA3C6a0f46ddd390b17486"
    private let baseURL = "https://perenual.com/api"

    // MARK: - Detalle de una planta por ID

    func fetchPlantDetail(id: Int) async throws -> PerenualPlantDetail {
        guard var components = URLComponents(string: "\(baseURL)/v2/species/details/\(id)") else {
            throw PerenualError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = components.url else { throw PerenualError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw PerenualError.serverError(http.statusCode)
        }
        do {
            return try JSONDecoder().decode(PerenualPlantDetail.self, from: data)
        } catch {
            throw PerenualError.decodingError(error)
        }
    }

    // MARK: - Búsqueda de plantas por nombre

    func searchPlants(query: String, page: Int = 1) async throws -> PerenualSearchResponse {
        guard var components = URLComponents(string: "\(baseURL)/v2/species-list") else {
            throw PerenualError.invalidURL
        }
        var items: [URLQueryItem] = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        if !query.isEmpty {
            items.append(URLQueryItem(name: "q", value: query))
        }
        components.queryItems = items
        guard let url = components.url else { throw PerenualError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw PerenualError.serverError(http.statusCode)
        }
        do {
            return try JSONDecoder().decode(PerenualSearchResponse.self, from: data)
        } catch {
            throw PerenualError.decodingError(error)
        }
    }

    // MARK: - Obtener guías de cuidado

    func fetchCareGuides(speciesId: Int) async throws -> [CareGuideSection] {
        guard var components = URLComponents(string: "\(baseURL)/species-care-guide-list") else {
            throw PerenualError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "species_id", value: "\(speciesId)")
        ]
        guard let url = components.url else { throw PerenualError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 { return [] }
        let result = try? JSONDecoder().decode(CareGuideResponse.self, from: data)
        return result?.data.first?.section ?? []
    }
}

// MARK: - Guías de cuidado

struct CareGuideResponse: Codable {
    let data: [CareGuideItem]
}

struct CareGuideItem: Codable {
    let id: Int?
    let common_name: String?
    let section: [CareGuideSection]?
}

struct CareGuideSection: Codable, Identifiable {
    let id: Int?
    let type: String?
    let description: String?
}

// MARK: - Errores

enum PerenualError: LocalizedError {
    case invalidURL
    case serverError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida."
        case .serverError(let code):
            return "Error del servidor (\(code)). Verifica tu API key de Perenual."
        case .decodingError(let error):
            return "Error al procesar la respuesta: \(error.localizedDescription)"
        }
    }
}
