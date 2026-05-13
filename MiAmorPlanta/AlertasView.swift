import SwiftUI

struct AlertasView: View {
    @ObservedObject private var storage = PlantStorage.shared

    // Generamos alertas dinámicas basadas en las plantas reales
    private var alertas: [AlertaItem] {
        var items: [AlertaItem] = []

        for plant in storage.plants {
            // Sensor detectó tierra seca
            if plant.hasSensor && plant.status == .seco {
                items.append(AlertaItem(
                    tipo: .sensor,
                    titulo: "Sensor",
                    subtitulo: "\(plant.name) necesita agua",
                    tiempo: "5 min",
                    emoji: plant.emoji
                ))
            }

            // Sin señal (tiene sensor pero status no está bien)
            if plant.hasSensor && plant.status == .pronto {
                items.append(AlertaItem(
                    tipo: .sinSenal,
                    titulo: "Sin señal",
                    subtitulo: "Sensor - \(plant.name) offline",
                    tiempo: "4h",
                    emoji: plant.emoji
                ))
            }

            // Recordatorio de riego
            if plant.daysUntilWatering <= 1 && plant.status != .seco {
                items.append(AlertaItem(
                    tipo: .recordatorio,
                    titulo: "Recordatorio",
                    subtitulo: "Regar \(plant.name)",
                    tiempo: "Mañana",
                    emoji: plant.emoji
                ))
            }

            // Recordatorio fertilizante
            if !plant.fertilizingFrequency.isEmpty {
                items.append(AlertaItem(
                    tipo: .fertilizante,
                    titulo: "Recordatorio",
                    subtitulo: "Regar \(plant.name)",
                    tiempo: "2h",
                    emoji: plant.emoji
                ))
            }

            // Completado (bien)
            if plant.status == .bien {
                items.append(AlertaItem(
                    tipo: .completado,
                    titulo: "Completado",
                    subtitulo: "Regaste \(plant.name)",
                    tiempo: "Ayer",
                    emoji: plant.emoji
                ))
            }
        }

        return items
    }

    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ───────────────────────────────────────────
                headerSection

                if alertas.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(alertas) { alerta in
                                AlertaRow(alerta: alerta)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack {
            Color("PlantDark").ignoresSafeArea(edges: .top)

            VStack(alignment: .leading, spacing: 4) {
                Text("Alertas y recordatorios")
                    .font(.custom("Georgia-Bold", size: 26))
                    .foregroundColor(Color("PlantCream"))

                HStack(spacing: 6) {
                    Text("Hoy  •  \(formattedDate)")
                        .font(.system(size: 13))
                        .foregroundColor(Color("PlantMuted"))

                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color("PlantAccent"))
                        .font(.system(size: 12))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .frame(maxHeight: 200)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(Color("PlantAccent").opacity(0.4))
            Text("Sin alertas por ahora")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("TextDark"))
            Text("Cuando alguna planta necesite\natención aparecerá aquí")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - Fecha formateada

    private var formattedDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateFormat = "d MMM yyyy"
        return f.string(from: Date())
    }
}

// MARK: - Modelo de alerta

enum TipoAlerta {
    case sensor, recordatorio, sinSenal, fertilizante, completado

    var color: Color {
        switch self {
        case .sensor:       return Color(hue: 0.11, saturation: 0.6, brightness: 0.95)
        case .recordatorio: return Color(hue: 0.35, saturation: 0.4, brightness: 0.92)
        case .sinSenal:     return Color(hue: 0.95, saturation: 0.3, brightness: 0.97)
        case .fertilizante: return Color(hue: 0.55, saturation: 0.3, brightness: 0.95)
        case .completado:   return Color(hue: 0.08, saturation: 0.15, brightness: 0.93)
        }
    }

    var borderColor: Color {
        switch self {
        case .sensor:       return Color(hue: 0.11, saturation: 0.5, brightness: 0.85)
        case .recordatorio: return Color(hue: 0.35, saturation: 0.35, brightness: 0.7)
        case .sinSenal:     return Color(hue: 0.95, saturation: 0.25, brightness: 0.75)
        case .fertilizante: return Color(hue: 0.55, saturation: 0.25, brightness: 0.7)
        case .completado:   return Color(hue: 0.08, saturation: 0.1, brightness: 0.75)
        }
    }

    var icon: String {
        switch self {
        case .sensor:       return "drop.fill"
        case .recordatorio: return "leaf.fill"
        case .sinSenal:     return "wifi.slash"
        case .fertilizante: return "leaf.fill"
        case .completado:   return "checkmark"
        }
    }

    var iconColor: Color {
        switch self {
        case .sensor:       return Color(hue: 0.11, saturation: 0.8, brightness: 0.8)
        case .recordatorio: return Color(hue: 0.35, saturation: 0.6, brightness: 0.55)
        case .sinSenal:     return Color(hue: 0.95, saturation: 0.5, brightness: 0.7)
        case .fertilizante: return Color(hue: 0.55, saturation: 0.6, brightness: 0.6)
        case .completado:   return Color(hue: 0.08, saturation: 0.2, brightness: 0.55)
        }
    }
}

struct AlertaItem: Identifiable {
    let id = UUID()
    let tipo: TipoAlerta
    let titulo: String
    let subtitulo: String
    let tiempo: String
    let emoji: String
}

// MARK: - Fila de alerta

struct AlertaRow: View {
    let alerta: AlertaItem

    var body: some View {
        HStack(spacing: 14) {

            // Ícono
            ZStack {
                Circle()
                    .fill(alerta.tipo.color)
                    .frame(width: 38, height: 38)
                Image(systemName: alerta.tipo.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(alerta.tipo.iconColor)
            }

            // Texto
            VStack(alignment: .leading, spacing: 3) {
                Text(alerta.titulo)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(alerta.tipo.iconColor)
                Text(alerta.subtitulo)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Tiempo
            Text(alerta.tiempo)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(alerta.tipo.color.opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(alerta.tipo.borderColor.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack { AlertasView() }
}
