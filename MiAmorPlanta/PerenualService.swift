import Foundation

// MARK: - Modelo de detalle de planta (API Perenual)

struct PerenualPlantDetail: Codable {
    let id: Int
    let common_name: String?
    let scientific_name: [String]?
    let description: String?
    let watering: String?
    let sunlight: [String]?
    let cycle: String?
    let growth_rate: String?
    let maintenance: String?
    let drought_tolerant: Bool?
    let tropical: Bool?
    let default_image: PerenualImage?

    /// Nombre a mostrar: común si existe, si no el científico, si no "Planta"
    var displayName: String {
        if let name = common_name, !name.isEmpty { return name.capitalized }
        if let sci = scientific_name?.first, !sci.isEmpty { return sci }
        return "Planta"
    }

    /// Nombre científico formateado
    var sciName: String {
        scientific_name?.first ?? ""
    }

    /// URL de imagen principal
    var imageURL: URL? {
        if let str = default_image?.medium_url ?? default_image?.regular_url ?? default_image?.original_url {
            return URL(string: str)
        }
        return nil
    }
}

struct PerenualImage: Codable {
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

struct PerenualSearchItem: Codable, Identifiable {
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

    /// ⚠️ Reemplaza con tu API key de https://perenual.com/api/key-upgrade
    private let apiKey = "YOUR_PERENUAL_API_KEY"
    private let baseURL = "https://perenual.com/api"

    // MARK: - Detalle de una planta por ID

    func fetchPlantDetail(id: Int) async throws -> PerenualPlantDetail {
        guard var components = URLComponents(string: "\(baseURL)/species/details/\(id)") else {
            throw PerenualError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        guard let url = components.url else { throw PerenualError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw PerenualError.serverError(http.statusCode)
        }

        do {
            let detail = try JSONDecoder().decode(PerenualPlantDetail.self, from: data)
            return detail
        } catch {
            throw PerenualError.decodingError(error)
        }
    }

    // MARK: - Búsqueda de plantas por nombre

    func searchPlants(query: String, page: Int = 1) async throws -> PerenualSearchResponse {
        guard var components = URLComponents(string: "\(baseURL)/species-list") else {
            throw PerenualError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        guard let url = components.url else { throw PerenualError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw PerenualError.serverError(http.statusCode)
        }

        do {
            let result = try JSONDecoder().decode(PerenualSearchResponse.self, from: data)
            return result
        } catch {
            throw PerenualError.decodingError(error)
        }
    }
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
