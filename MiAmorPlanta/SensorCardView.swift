import SwiftUI

struct SensorCardView: View {
    let plant: Plant
    @State private var watered = false

    // Simula "hace X min" con un valor fijo por planta
    private var lastSeen: String {
        plant.hasSensor ? "Hace \(abs(plant.name.count % 12) + 1) min" : "Hace 4h"
    }

    private var sensorName: String {
        "Sensor-\(plant.name.components(separatedBy: " ").first ?? plant.name)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Barra de color izquierda + contenido ─────────────────
            HStack(spacing: 0) {

                // Barra lateral de color según estado
                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor)
                    .frame(width: 5)
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {

                    // Fila superior: nombre + indicador activo
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(sensorName)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color("TextDark"))

                            Text("\(plant.name) · \(plant.location)")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Circle()
                            .fill(plant.hasSensor ? Color("StatusGreen") : Color("StatusRed"))
                            .frame(width: 10, height: 10)
                    }

                    // Humedad destacada
                    if plant.status == .seco {
                        Text("Humedad del suelo: \(plant.humidity)%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("StatusRed"))
                    } else {
                        Text("Humedad del suelo: \(plant.humidity)%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("StatusGreen"))
                    }

                    // Barra de humedad
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(humidityBarColor)
                                .frame(width: geo.size.width * CGFloat(plant.humidity) / 100, height: 6)
                        }
                    }
                    .frame(height: 6)

                    // Fila inferior: badge estado + acción + tiempo
                    HStack(spacing: 8) {
                        // Badge
                        Text(badgeText)
                            .font(.system(size: 11, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(badgeBackground)
                            .foregroundColor(badgeForeground)
                            .cornerRadius(20)

                        Spacer()

                        if plant.status == .seco {
                            Button(action: { withAnimation { watered.toggle() } }) {
                                Text(watered ? "✓ Regada" : "Regar ahora")
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(watered ? Color("StatusGreen") : Color("PlantDark"))
                                    .foregroundColor(Color("PlantCream"))
                                    .cornerRadius(20)
                            }
                        } else {
                            Text(lastSeen)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.leading, 12)
                .padding(.trailing, 14)
                .padding(.vertical, 14)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
    }

    // MARK: - Helpers de color

    private var barColor: Color {
        switch plant.status {
        case .seco:   return Color("StatusRed")
        case .bien:   return Color("StatusGreen")
        case .pronto: return Color("StatusBlue")
        }
    }

    private var humidityBarColor: Color {
        if plant.humidity < 25 { return Color("StatusRed") }
        if plant.humidity < 50 { return Color(hue: 0.1, saturation: 0.8, brightness: 0.85) }
        return Color("StatusGreen")
    }

    private var badgeText: String {
        switch plant.status {
        case .seco:   return "Tierra seca"
        case .bien:   return "Humedad Ok"
        case .pronto: return "Regar pronto"
        }
    }

    private var badgeBackground: Color {
        switch plant.status {
        case .seco:   return Color("StatusRed").opacity(0.1)
        case .bien:   return Color("StatusGreen").opacity(0.1)
        case .pronto: return Color("StatusBlue").opacity(0.1)
        }
    }

    private var badgeForeground: Color {
        switch plant.status {
        case .seco:   return Color("StatusRed")
        case .bien:   return Color("StatusGreen")
        case .pronto: return Color("StatusBlue")
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SensorCardView(plant: Plant(
            name: "Pothos Dorado", location: "Sala",
            status: .seco, hasSensor: true, emoji: "🪴",
            humidity: 18
        ))
        SensorCardView(plant: Plant(
            name: "Orquídea Rosa", location: "Recámara",
            status: .bien, hasSensor: true, emoji: "🌺",
            humidity: 62
        ))
    }
    .padding()
    .background(Color("BgLight"))
}
