import SwiftUI

struct SensorCardView: View {
    let plant: Plant
    @StateObject private var sensorVM: PlantaViewModel
    @State private var watered = false

    init(plant: Plant) {
        self.plant = plant
        _sensorVM = StateObject(
            wrappedValue: PlantaViewModel(plantId: plant.id.uuidString)
        )
    }

    private var humedadReal: Int { sensorVM.humedadCruda }
    private var temperaturaReal: Double { sensorVM.temperatura }
    private var estadoHumedadReal: String { sensorVM.estadoHumedad }
    private var estadoTempReal: String { sensorVM.estadoTemperatura }
    private var esSeco: Bool { humedadReal < 30 }

    private var sensorName: String {
        "Sensor-\(plant.name.components(separatedBy: " ").first ?? plant.name)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {

                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor)
                    .frame(width: 5)
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 10) {

                    // ── Encabezado ───────────────────────────────────
                    HStack {
                        HStack(spacing: 8) {
                            Text(plant.emoji)
                                .font(.system(size: 28))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(plant.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color("TextDark"))
                                Text("\(plant.location) · \(sensorName)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer()

                        // Indicador en vivo — usa cargando en lugar de isConnected
                        HStack(spacing: 4) {
                            Circle()
                                .fill(sensorVM.cargando ? Color.gray : Color("StatusGreen"))
                                .frame(width: 8, height: 8)
                            Text(sensorVM.cargando ? "Conectando..." : "En vivo")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(sensorVM.cargando ? .gray : Color("StatusGreen"))
                        }
                    }

                    // ── Métricas ─────────────────────────────────────
                    HStack(spacing: 8) {

                        VStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                            Text("\(humedadReal)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(esSeco ? Color("StatusRed") : Color("StatusGreen"))
                            Text("Humedad")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(esSeco ? Color("StatusRed").opacity(0.07) : Color.blue.opacity(0.07))
                        .cornerRadius(12)

                        VStack(spacing: 4) {
                            Image(systemName: "thermometer.medium")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                            Text(String(format: "%.1f°", temperaturaReal))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color("TextDark"))
                            Text("Temp °C")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.07))
                        .cornerRadius(12)

                        VStack(spacing: 4) {
                            Image(systemName: esSeco ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                .foregroundColor(esSeco ? Color("StatusRed") : Color("StatusGreen"))
                                .font(.system(size: 14))
                            Text(esSeco ? "Seco" : "Bien")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(esSeco ? Color("StatusRed") : Color("StatusGreen"))
                            Text("Estado")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(esSeco ? Color("StatusRed").opacity(0.07) : Color("StatusGreen").opacity(0.07))
                        .cornerRadius(12)
                    }

                    // ── Barra de humedad ─────────────────────────────
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Nivel de humedad del suelo")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Spacer()
                            Text(estadoHumedadReal)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(esSeco ? Color("StatusRed") : Color("StatusGreen"))
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.12))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(humidityBarColor)
                                    .frame(
                                        width: geo.size.width * min(CGFloat(humedadReal) / 100, 1.0),
                                        height: 8
                                    )
                                    .animation(.easeInOut(duration: 0.5), value: humedadReal)
                            }
                        }
                        .frame(height: 8)
                    }

                    // ── Estado temperatura ───────────────────────────
                    HStack(spacing: 6) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        Text(estadoTempReal)
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                        Spacer()
                        Text("Actualizado ahora")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }

                    // ── Botón regar ──────────────────────────────────
                    if esSeco {
                        Button(action: { withAnimation { watered.toggle() } }) {
                            HStack(spacing: 6) {
                                Image(systemName: watered ? "checkmark.circle.fill" : "drop.fill")
                                Text(watered ? "✓ Regada" : "Regar ahora")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(watered ? Color("StatusGreen") : Color("PlantDark"))
                            .foregroundColor(Color("PlantCream"))
                            .cornerRadius(20)
                        }
                    } else {
                        HStack {
                            Text("✅ Todo bien con \(plant.name)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("StatusGreen"))
                            Spacer()
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

    private var barColor: Color {
        esSeco ? Color("StatusRed") : Color("StatusGreen")
    }

    private var humidityBarColor: Color {
        if humedadReal < 25 { return Color("StatusRed") }
        if humedadReal < 50 { return Color(hue: 0.1, saturation: 0.8, brightness: 0.85) }
        return Color("StatusGreen")
    }
}

#Preview {
    VStack(spacing: 16) {
        SensorCardView(
            plant: Plant(
                name: "Aguacate", location: "Jardín",
                status: .seco, hasSensor: true, emoji: "🥑"
            )
        )
    }
    .padding()
    .background(Color("BgLight"))
}
