import SwiftUI

struct PerenualPlantDetailView: View {
    let plantId: Int
    let plantName: String

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storage = PlantStorage.shared
    @State private var detail: PerenualPlantDetail?
    @State private var careGuides: [CareGuideSection] = []
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
                            VStack(alignment: .leading, spacing: 4) {
                                Text(detail.displayName)
                                    .font(.custom("Georgia-Bold", size: 26))
                                    .foregroundColor(Color("TextDark"))
                                if !detail.sciName.isEmpty {
                                    Text(detail.sciName)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                                if let family = detail.family, !family.isEmpty {
                                    Text("Familia: \(family)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                            }

                            // Chips resumen
                            infoChips(detail: detail)

                            // Riego
                            infoSection(title: "Riego", icon: "drop.fill", iconColor: .blue) {
                                VStack(spacing: 12) {
                                    careRow(icon: "drop", color: .blue,
                                            label: "Frecuencia",
                                            value: wateringLabel(detail.watering))
                                    if let bench = detail.watering_general_benchmark,
                                       let val = bench.value, let unit = bench.unit {
                                        careRow(icon: "calendar",
                                                color: Color("PlantAccent"),
                                                label: "Referencia",
                                                value: "Cada \(val) \(unit == "days" ? "días" : unit)")
                                    }
                                }
                            }

                            // Luz solar
                            infoSection(title: "Luz solar", icon: "sun.max", iconColor: .orange) {
                                VStack(spacing: 8) {
                                    if let sunList = detail.sunlight, !sunList.isEmpty {
                                        ForEach(sunList, id: \.self) { s in
                                            HStack(spacing: 10) {
                                                Image(systemName: sunlightIcon(s))
                                                    .foregroundColor(.orange.opacity(0.7))
                                                    .frame(width: 18)
                                                Text(sunlightShort(s))
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color("TextDark"))
                                                Spacer()
                                            }
                                        }
                                    } else {
                                        Text("Luz indirecta")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            // Cuidados generales
                            infoSection(title: "Cuidados", icon: "leaf", iconColor: Color("PlantAccent")) {
                                VStack(spacing: 12) {
                                    careRow(icon: "arrow.up.right", color: Color("PlantAccent"),
                                            label: "Crecimiento",
                                            value: growthLabel(detail.growth_rate))
                                    careRow(icon: "wrench", color: .gray,
                                            label: "Mantenimiento",
                                            value: maintenanceLabel(detail.maintenance))
                                    careRow(icon: "chart.bar", color: .gray,
                                            label: "Dificultad",
                                            value: careLevelLabel(detail.care_level))
                                    careRow(icon: "arrow.clockwise", color: .gray,
                                            label: "Ciclo de vida",
                                            value: cycleLabel(detail.cycle))
                                    if let typeStr = detail.type, !typeStr.isEmpty {
                                        careRow(icon: "tag", color: .gray,
                                                label: "Tipo",
                                                value: typeStr.capitalized)
                                    }
                                }
                            }

                            // Poda
                            if let months = detail.pruning_month, !months.isEmpty {
                                infoSection(title: "Poda", icon: "scissors", iconColor: .gray) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 6) {
                                            ForEach(months, id: \.self) { m in
                                                Text(monthShort(m))
                                                    .font(.system(size: 12, weight: .medium))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 5)
                                                    .background(Color("PlantAccent").opacity(0.1))
                                                    .foregroundColor(Color("PlantAccent"))
                                                    .cornerRadius(8)
                                            }
                                        }
                                        if let pc = detail.pruning_count,
                                           let amt = pc.amount, let intv = pc.interval {
                                            Text("\(amt) vez por \(pruningInterval(intv))")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }

                            // Suelo
                            if let soils = detail.soil, !soils.isEmpty {
                                infoSection(title: "Tipo de suelo", icon: "circle.grid.3x3", iconColor: .brown) {
                                    HStack(spacing: 8) {
                                        ForEach(soils, id: \.self) { s in
                                            pill(text: soilLabel(s), color: Color("PlantDark"))
                                        }
                                    }
                                }
                            }

                            // Plagas
                            if let pests = detail.pest_susceptibility, !pests.isEmpty {
                                infoSection(title: "Plagas comunes", icon: "ant", iconColor: .orange) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(pests, id: \.self) { p in
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(Color.orange.opacity(0.5))
                                                    .frame(width: 5, height: 5)
                                                Text(p.capitalized)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(Color("TextDark"))
                                            }
                                        }
                                    }
                                }
                            }

                            // Origen
                            if let origins = detail.origin, !origins.isEmpty {
                                infoSection(title: "Origen", icon: "globe.americas", iconColor: .gray) {
                                    Text(origins.joined(separator: ", "))
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                            }

                            // Características
                            let features = buildFeatures(detail)
                            if !features.isEmpty {
                                infoSection(title: "Características", icon: "info.circle", iconColor: .gray) {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                        ForEach(features, id: \.label) { f in
                                            featurePill(f.label, f.color)
                                        }
                                    }
                                }
                            }

                            // Temporadas
                            let hasSeasons = (detail.flowering_season != nil && detail.flowers?.isTrue == true)
                                || (detail.harvest_season != nil && detail.fruits?.isTrue == true)
                            if hasSeasons {
                                infoSection(title: "Temporadas", icon: "calendar", iconColor: .gray) {
                                    VStack(spacing: 8) {
                                        if let fs = detail.flowering_season, detail.flowers?.isTrue == true {
                                            careRow(icon: "sparkle", color: .pink,
                                                    label: "Floración",
                                                    value: seasonLabel(fs))
                                        }
                                        if let hs = detail.harvest_season, detail.fruits?.isTrue == true {
                                            careRow(icon: "leaf.circle", color: Color("PlantAccent"),
                                                    label: "Cosecha",
                                                    value: seasonLabel(hs))
                                        }
                                    }
                                }
                            }

                            // Atrae
                            if let attracts = detail.attracts, !attracts.isEmpty {
                                infoSection(title: "Atrae", icon: "wind", iconColor: .gray) {
                                    HStack(spacing: 8) {
                                        ForEach(attracts, id: \.self) { a in
                                            pill(text: a.capitalized, color: Color("PlantDark").opacity(0.7))
                                        }
                                    }
                                }
                            }

                            // Propagación
                            if let props = detail.propagation, !props.isEmpty {
                                infoSection(title: "Propagación", icon: "arrow.branch", iconColor: Color("PlantAccent")) {
                                    HStack(spacing: 8) {
                                        ForEach(props, id: \.self) { p in
                                            pill(text: p.capitalized, color: Color("PlantAccent"))
                                        }
                                    }
                                }
                            }

                            // Guías de cuidado
                            if !careGuides.isEmpty {
                                infoSection(title: "Guías de cuidado", icon: "book", iconColor: Color("PlantDark")) {
                                    VStack(alignment: .leading, spacing: 14) {
                                        ForEach(careGuides) { section in
                                            if let type = section.type, let desc = section.description {
                                                VStack(alignment: .leading, spacing: 6) {
                                                    Text(careGuideTypeLabel(type))
                                                        .font(.system(size: 13, weight: .semibold))
                                                        .foregroundColor(Color("PlantDark"))
                                                    Text(desc)
                                                        .font(.system(size: 13))
                                                        .foregroundColor(Color("TextDark"))
                                                        .lineSpacing(4)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }

                            // Descripción
                            if let desc = detail.description, !desc.isEmpty {
                                infoSection(title: "Descripción", icon: "text.alignleft", iconColor: .gray) {
                                    Text(desc)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("TextDark"))
                                        .lineSpacing(5)
                                        .fixedSize(horizontal: false, vertical: true)
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
                            .padding(.bottom, 40)
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

    // MARK: - Hero image

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
            @unknown default: EmptyView()
            }
        }
        .frame(maxWidth: .infinity).frame(height: 280).clipped()
    }

    // MARK: - Chips

    private func infoChips(detail: PerenualPlantDetail) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let w = detail.watering {
                    chip(text: wateringShort(w), color: .blue)
                }
                if let c = detail.cycle {
                    chip(text: cycleShort(c), color: .purple)
                }
                if let s = detail.sunlight?.first {
                    chip(text: sunlightShort(s), color: .orange)
                }
                if detail.tropical?.isTrue == true        { chip(text: "Tropical", color: .green) }
                if detail.indoor?.isTrue == true           { chip(text: "Interior", color: .blue) }
                if detail.drought_tolerant?.isTrue == true { chip(text: "Resistente a sequía", color: .orange) }
                if detail.poisonous_to_pets?.isTrue == true { chip(text: "Tóxica mascotas", color: .red) }
            }
        }
    }

    // MARK: - Sección con ícono SF en el título

    private func infoSection<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("TextDark"))
            }
            content()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func careRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 18)
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("TextDark"))
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 180, alignment: .trailing)
        }
    }

    private func chip(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(color.opacity(0.85))
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(color.opacity(0.08))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(color.opacity(0.2), lineWidth: 1))
    }

    private func pill(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(color)
            .cornerRadius(20)
    }

    private func featurePill(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(color.opacity(0.08))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Features builder

    private struct Feature { let label: String; let color: Color }

    private func buildFeatures(_ d: PerenualPlantDetail) -> [Feature] {
        var list: [Feature] = []
        if d.drought_tolerant?.isTrue == true   { list.append(.init(label: "Resistente a sequía", color: .orange)) }
        if d.tropical?.isTrue == true            { list.append(.init(label: "Tropical", color: .green)) }
        if d.indoor?.isTrue == true              { list.append(.init(label: "Interior", color: .blue)) }
        if d.medicinal?.isTrue == true           { list.append(.init(label: "Medicinal", color: Color("PlantAccent"))) }
        if d.edible_fruit?.isTrue == true        { list.append(.init(label: "Fruto comestible", color: .pink)) }
        if d.edible_leaf?.isTrue == true         { list.append(.init(label: "Hoja comestible", color: .green)) }
        if d.flowers?.isTrue == true             { list.append(.init(label: "Florece", color: .pink)) }
        if d.salt_tolerant?.isTrue == true       { list.append(.init(label: "Tolera sal", color: .gray)) }
        if d.thorny?.isTrue == true              { list.append(.init(label: "Espinosa", color: .red)) }
        if d.invasive?.isTrue == true            { list.append(.init(label: "Invasiva", color: .orange)) }
        if d.poisonous_to_humans?.isTrue == true { list.append(.init(label: "Tóxica · humanos", color: .red)) }
        if d.poisonous_to_pets?.isTrue == true   { list.append(.init(label: "Tóxica · mascotas", color: .red)) }
        return list
    }

    // MARK: - Traducciones

    private func wateringLabel(_ w: String?) -> String {
        switch w?.lowercased() {
        case "frequent": return "Frecuente · cada 2-3 días"
        case "average":  return "Moderado · cada semana"
        case "minimum":  return "Mínimo · cada 2-3 semanas"
        case "none":     return "Casi nulo"
        default:         return "Moderado · cada semana"
        }
    }

    private func wateringShort(_ w: String) -> String {
        switch w.lowercased() {
        case "frequent": return "Riego frecuente"
        case "average":  return "Riego moderado"
        case "minimum":  return "Riego mínimo"
        case "none":     return "Sin riego"
        default:         return "Riego moderado"
        }
    }

    private func sunlightShort(_ v: String) -> String {
        let l = v.lowercased()
        if l.contains("full sun")   { return "Sol directo" }
        if l.contains("part shade") { return "Semisombra" }
        if l.contains("full shade") { return "Sombra total" }
        if l.contains("filtered")   { return "Luz filtrada" }
        if l.contains("indirect")   { return "Luz indirecta" }
        return v.capitalized
    }

    private func sunlightIcon(_ v: String) -> String {
        let l = v.lowercased()
        if l.contains("full sun")   { return "sun.max.fill" }
        if l.contains("part shade") { return "cloud.sun.fill" }
        if l.contains("full shade") { return "cloud.fill" }
        return "sun.min.fill"
    }

    private func growthLabel(_ g: String?) -> String {
        switch g?.lowercased() {
        case "high":    return "Rápido"
        case "regular": return "Moderado"
        case "low":     return "Lento"
        default:        return "Moderado"
        }
    }

    private func maintenanceLabel(_ m: String?) -> String {
        switch m?.lowercased() {
        case "high":     return "Alto"
        case "moderate": return "Moderado"
        case "low":      return "Bajo"
        default:         return "Moderado"
        }
    }

    private func careLevelLabel(_ c: String?) -> String {
        switch c?.lowercased() {
        case "easy":   return "Fácil"
        case "medium": return "Intermedio"
        case "hard":   return "Avanzado"
        default:       return c?.capitalized ?? "Moderado"
        }
    }

    private func cycleLabel(_ c: String?) -> String {
        switch c?.lowercased() {
        case "perennial": return "Perenne"
        case "annual":    return "Anual"
        case "biennial":  return "Bienal"
        case "biannual":  return "Bianual"
        default:          return c?.capitalized ?? "Perenne"
        }
    }

    private func cycleShort(_ c: String) -> String { cycleLabel(c) }

    private func soilLabel(_ s: String) -> String {
        switch s.lowercased() {
        case "loam":  return "Franco"
        case "clay":  return "Arcilloso"
        case "sand":  return "Arenoso"
        case "chalk": return "Calcáreo"
        default:      return s.capitalized
        }
    }

    private func seasonLabel(_ s: String) -> String {
        let map: [String: String] = [
            "spring": "Primavera", "summer": "Verano",
            "fall": "Otoño", "autumn": "Otoño", "winter": "Invierno"
        ]
        return map[s.lowercased()] ?? s.capitalized
    }

    private func monthShort(_ m: String) -> String {
        let map: [String: String] = [
            "january": "Ene", "february": "Feb", "march": "Mar", "april": "Abr",
            "may": "May", "june": "Jun", "july": "Jul", "august": "Ago",
            "september": "Sep", "october": "Oct", "november": "Nov", "december": "Dic"
        ]
        return map[m.lowercased()] ?? String(m.prefix(3)).capitalized
    }

    private func pruningInterval(_ i: String) -> String {
        switch i.lowercased() {
        case "year":  return "año"
        case "month": return "mes"
        case "week":  return "semana"
        default:      return i
        }
    }

    private func careGuideTypeLabel(_ t: String) -> String {
        switch t.lowercased() {
        case "watering": return "Riego"
        case "sunlight": return "Luz solar"
        case "pruning":  return "Poda"
        default:         return t.capitalized
        }
    }

    // MARK: - Cargar

    private func loadDetail() async {
        isLoading = true
        errorMsg = nil
        async let detailTask = PerenualService.shared.fetchPlantDetail(id: plantId)
        async let guidesTask = PerenualService.shared.fetchCareGuides(speciesId: plantId)
        do {
            detail = try await detailTask
            careGuides = (try? await guidesTask) ?? []
        } catch {
            errorMsg = "No se pudo cargar la información.\nIntenta de nuevo."
            print("❌ Error detalle: \(error)")
        }
        isLoading = false
    }

    // MARK: - Agregar a colección

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
