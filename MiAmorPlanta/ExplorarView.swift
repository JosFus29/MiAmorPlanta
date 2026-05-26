import SwiftUI

struct ExplorarView: View {

    @State private var query = ""
    @State private var results: [PerenualSearchItem] = []
    @State private var isLoading = false
    @State private var errorMsg: String?
    @State private var currentPage = 1
    @State private var lastPage = 1
    @State private var hasSearched = false
    @State private var selectedPlant: PerenualSearchItem?

    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ────────────────────────────────────────────
                ZStack {
                    Color("PlantDark").ignoresSafeArea(edges: .top)
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("EXPLORAR")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color("PlantMuted"))
                                    .kerning(1.2)
                                Text("Catálogo de plantas")
                                    .font(.custom("Georgia-Bold", size: 22))
                                    .foregroundColor(Color("PlantCream"))
                            }
                            Spacer()
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color("PlantMuted"))
                        }
                        .padding(.horizontal, 20)

                        // Barra de búsqueda
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Buscar planta en español o inglés…", text: $query)
                                .font(.system(size: 14))
                                .foregroundColor(Color("TextDark"))
                                .onSubmit { Task { await search(reset: true) } }
                            if !query.isEmpty {
                                Button(action: {
                                    query = ""
                                    results = []
                                    hasSearched = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                    }
                    .padding(.top, 56)
                }
                .frame(height: 150)

                // ── Contenido ─────────────────────────────────────────
                if isLoading && results.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        ProgressView()
                            .tint(Color("PlantAccent"))
                            .scaleEffect(1.3)
                        Text("Buscando plantas…")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else if let err = errorMsg {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.orange)
                        Text(err)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Reintentar") { Task { await search(reset: true) } }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("PlantAccent"))
                    }
                    Spacer()
                } else if results.isEmpty && hasSearched {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color("PlantAccent").opacity(0.4))
                        Text("Sin resultados para \"\(query)\"")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else if results.isEmpty && !hasSearched {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(Color("PlantAccent").opacity(0.35))
                        Text("Busca cualquier planta")
                            .font(.custom("Georgia-Bold", size: 18))
                            .foregroundColor(Color("TextDark"))
                        Text("Encuentra información detallada:\nriego, luz solar, poda, suelo y más")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button(action: { Task { await search(reset: true, browseAll: true) } }) {
                            Label("Ver plantas populares", systemImage: "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 10)
                                .background(Color("PlantDark"))
                                .cornerRadius(20)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 32)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(results) { item in
                                Button(action: { selectedPlant = item }) {
                                    PlantAPIRow(item: item)
                                }
                                .buttonStyle(.plain)
                            }

                            // Paginación
                            if currentPage < lastPage {
                                Button(action: { Task { await search(reset: false) } }) {
                                    HStack(spacing: 8) {
                                        if isLoading {
                                            ProgressView()
                                                .tint(Color("PlantAccent"))
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "arrow.down.circle")
                                        }
                                        Text(isLoading ? "Cargando…" : "Ver más plantas")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color("PlantAccent"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color("PlantAccent").opacity(0.08))
                                    .cornerRadius(12)
                                }
                                .disabled(isLoading)
                            }

                            Color.clear.frame(height: 20)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedPlant) { item in
            PerenualPlantDetailView(plantId: item.id, plantName: item.displayName)
        }
    }

    // MARK: - Búsqueda

    private func search(reset: Bool, browseAll: Bool = false) async {
        if reset {
            currentPage = 1
            results = []
        } else {
            currentPage += 1
        }
        isLoading = true
        errorMsg = nil
        hasSearched = true

        do {
            let q = browseAll ? "" : query
            let resp = try await PerenualService.shared.searchPlants(query: q, page: currentPage)
            if reset {
                results = resp.data
            } else {
                results.append(contentsOf: resp.data)
            }
            lastPage = resp.last_page ?? 1
        } catch {
            errorMsg = "No se pudo conectar al catálogo.\nVerifica tu conexión."
        }
        isLoading = false
    }
}

// MARK: - Fila de resultado

struct PlantAPIRow: View {
    let item: PerenualSearchItem

    var body: some View {
        HStack(spacing: 14) {
            // Imagen
            AsyncImage(url: item.imageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .empty:
                    Color("PlantAccent").opacity(0.2)
                        .overlay(ProgressView().tint(Color("PlantAccent")).scaleEffect(0.7))
                case .failure:
                    Color("PlantAccent").opacity(0.15)
                        .overlay(Image(systemName: "leaf.fill")
                            .foregroundColor(Color("PlantAccent").opacity(0.5)))
                @unknown default: EmptyView()
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Datos
            VStack(alignment: .leading, spacing: 5) {
                Text(item.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("TextDark"))
                    .lineLimit(1)

                if let sci = item.scientific_name?.first, !sci.isEmpty {
                    Text(sci)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .italic()
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    if let w = item.watering {
                        miniChip(wateringEmoji(w) + " " + wateringShort(w), .blue)
                    }
                    if let s = item.sunlight?.first {
                        miniChip("☀️ " + sunShort(s), .yellow)
                    }
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func miniChip(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(color.opacity(0.9))
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.1))
            .cornerRadius(10)
    }

    private func wateringEmoji(_ w: String) -> String {
        switch w.lowercased() {
        case "frequent": return "💧💧💧"
        case "average":  return "💧💧"
        case "minimum":  return "💧"
        case "none":     return "🏜️"
        default:         return "💧"
        }
    }
    private func wateringShort(_ w: String) -> String {
        switch w.lowercased() {
        case "frequent": return "Frecuente"
        case "average":  return "Moderado"
        case "minimum":  return "Mínimo"
        case "none":     return "Sin riego"
        default:         return "Moderado"
        }
    }
    private func sunShort(_ v: String) -> String {
        let l = v.lowercased()
        if l.contains("full sun")   { return "Sol directo" }
        if l.contains("part shade") { return "Semisombra" }
        if l.contains("full shade") { return "Sombra" }
        return "Luz indirecta"
    }
}

#Preview {
    NavigationStack { ExplorarView() }
}
