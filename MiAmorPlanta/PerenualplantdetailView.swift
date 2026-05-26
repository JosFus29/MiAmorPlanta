import SwiftUI

struct PerenualPlantDetailView: View {
    let plantId: Int
    let plantName: String

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storage = PlantStorage.shared
    @State private var detail: PerenualPlantDetail?
    @State private var isLoading = true
    @State private var errorMsg: String?
    @State private var added = false

    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()

            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(Color("PlantAccent"))
                        .scaleEffect(1.4)
                    Text("Cargando información...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            } else if let error = errorMsg {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else if let detail = detail {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        heroImage(detail: detail)

                        VStack(alignment: .leading, spacing: 20) {

                            // Nombre
                            VStack(alignment: .leading, spacing: 6) {
                                Text(detail.displayName)
                                    .font(.custom("Georgia-Bold", size: 26))
                                    .foregroundColor(Color("TextDark"))
                                Text(detail.sciName)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .italic()
                            }

                            // Chips resumen
                            infoChips(detail: detail)

                            // Descripción
                            if let desc = detail.description, !desc.isEmpty {
                                infoSection(title: "📋 Descripción") {
                                    Text(desc)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("TextDark"))
                                        .lineSpacing(5)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            // Cuidados — siempre muestra algo útil en español
                            infoSection(title: "🌱 Cuidados") {
                                VStack(spacing: 12) {
                                    careRow(icon: "drop.fill",
                                            color: .blue,
                                            label: "Riego",
                                            value: wateringLabel(detail.watering))
                                    careRow(icon: "sun.max.fill",
                                            color: .yellow,
                                            label: "Luz solar",
                                            value: sunlightLabel(detail.sunlight))
                                    careRow(icon: "arrow.up.forward",
                                            color: .green,
                                            label: "Crecimiento",
                                            value: growthLabel(detail.growth_rate))
                                    careRow(icon: "wrench.fill",
                                            color: .orange,
                                            label: "Mantenimiento",
                                            value: maintenanceLabel(detail.maintenance))
                                    careRow(icon: "leaf.fill",
                                            color: Color("PlantAccent"),
                                            label: "Ciclo de vida",
                                            value: cycleLabel(detail.cycle))
                                }
                            }

                            // Características
                            let hasBadges = detail.drought_tolerant == true || detail.tropical == true
                            infoSection(title: "✨ Características") {
                                if hasBadges {
                                    HStack(spacing: 12) {
                                        if detail.drought_tolerant == true {
                                            badge(text: "🏜️ Resistente a sequía", color: .orange)
                                        }
                                        if detail.tropical == true {
                                            badge(text: "🌴 Tropical", color: .green)
                                        }
                                    }
                                } else {
                                    Text("Sin características especiales registradas.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                            }

                            // Botón agregar
                            Button(action: { addToCollection(detail) }) {
                                HStack(spacing: 10) {
                                    Image(systemName: added ? "checkmark.circle.fill" : "plus.circle.fill")
                                    Text(added ? "Agregada a tu colección" : "Agregar a mi colección")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(added ? Color.gray : Color("PlantDark"))
                                .cornerRadius(16)
                            }
                            .disabled(added)
                            .padding(.top, 8)
                            .padding(.bottom, 30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }

            // Botón regresar flotante
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 56)
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .task { await loadDetail() }
    }

    // MARK: - Imagen hero

    private func heroImage(detail: PerenualPlantDetail) -> some View {
        AsyncImage(url: detail.imageURL) { phase in
            switch phase {
            case .success(let img):
                img.resizable().scaledToFill()
            case .empty:
                Color("PlantAccent").opacity(0.2)
                    .overlay(ProgressView().tint(Color("PlantAccent")))
            case .failure:
                Color("PlantAccent").opacity(0.15)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("PlantAccent").opacity(0.4))
                    )
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .clipped()
    }

    // MARK: - Chips

    private func infoChips(detail: PerenualPlantDetail) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                if let watering = detail.watering {
                    chip(text: wateringEmoji(watering) + " " + wateringLabel(watering), color: .blue)
                }
                if let cycle = detail.cycle {
                    chip(text: "🔄 " + cycleLabel(cycle), color: .purple)
                }
                if let sun = detail.sunlight?.first {
                    chip(text: "☀️ " + sunlightShort(sun), color: .yellow)
                }
                if detail.tropical == true {
                    chip(text: "🌴 Tropical", color: .green)
                }
                if detail.drought_tolerant == true {
                    chip(text: "🏜️ Sequía", color: .orange)
                }
            }
        }
    }

    // MARK: - Sección

    private func infoSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("TextDark"))
            content()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Fila de cuidado

    private func careRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("TextDark"))
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 180, alignment: .trailing)
        }
    }

    // MARK: - Helpers visuales

    private func chip(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(color.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .cornerRadius(20)
    }

    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(20)
    }

    // MARK: - Traducciones en español

    private func wateringLabel(_ watering: String?) -> String {
        switch watering?.lowercased() {
        case "frequent": return "Frecuente · cada 2-3 días"
        case "average":  return "Moderado · cada semana"
        case "minimum":  return "Mínimo · cada 2-3 semanas"
        case "none":     return "Casi nulo · muy resistente"
        default:         return "Moderado · cada semana"
        }
    }

    private func sunlightLabel(_ sunlight: [String]?) -> String {
        guard let list = sunlight, !list.isEmpty else { return "Luz indirecta" }
        return list.map { sunlightShort($0) }.joined(separator: ", ")
    }

    private func sunlightShort(_ value: String) -> String {
        let v = value.lowercased()
        if v.contains("full sun")     { return "Sol directo" }
        if v.contains("part shade")   { return "Semisombra" }
        if v.contains("full shade")   { return "Sombra total" }
        if v.contains("filtered")     { return "Luz filtrada" }
        if v.contains("indirect")     { return "Luz indirecta" }
        return value.capitalized
    }

    private func growthLabel(_ growth: String?) -> String {
        switch growth?.lowercased() {
        case "high":    return "Rápido"
        case "regular": return "Moderado"
        case "low":     return "Lento"
        default:        return "Moderado"
        }
    }

    private func maintenanceLabel(_ maintenance: String?) -> String {
        switch maintenance?.lowercased() {
        case "high":     return "Alto · atención frecuente"
        case "moderate": return "Moderado · revisión semanal"
        case "low":      return "Bajo · muy fácil de cuidar"
        default:         return "Moderado · revisión semanal"
        }
    }

    private func cycleLabel(_ cycle: String?) -> String {
        switch cycle?.lowercased() {
        case "perennial": return "Perenne · vive varios años"
        case "annual":    return "Anual · ciclo de un año"
        case "biennial":  return "Bienal · ciclo de dos años"
        case "biannual":  return "Bianual"
        default:          return cycle?.capitalized ?? "Perenne"
        }
    }

    private func wateringEmoji(_ watering: String) -> String {
        switch watering.lowercased() {
        case "frequent": return "💧💧💧"
        case "average":  return "💧💧"
        case "minimum":  return "💧"
        case "none":     return "🏜️"
        default:         return "💧"
        }
    }

    // MARK: - Cargar detalle

    private func loadDetail() async {
        isLoading = true
        errorMsg = nil
        do {
            detail = try await PerenualService.shared.fetchPlantDetail(id: plantId)
        } catch {
            errorMsg = "No se pudo cargar la información.\nIntenta de nuevo."
            print("❌ Error detalle: \(error)")
        }
        isLoading = false
    }

    // MARK: - Agregar a colección (guarda imagen)

    private func addToCollection(_ detail: PerenualPlantDetail) {
        let status: PlantStatus = {
            switch detail.watering?.lowercased() {
            case "frequent": return .seco
            case "minimum":  return .bien
            default:         return .pronto
            }
        }()

        let imageStr = detail.default_image?.medium_url ?? detail.default_image?.regular_url

        let newPlant = Plant(
            name: detail.displayName,
            location: "Sin ubicación",
            status: status,
            hasSensor: false,
            emoji: "🌿",
            imageURL: imageStr
        )

        storage.add(newPlant)
        withAnimation { added = true }
    }
}

#Preview {
    NavigationStack {
        PerenualPlantDetailView(plantId: 1, plantName: "European Silver Fir")
    }
}
