import SwiftUI

struct PlantDetailView: View {
    let plant: Plant
    @Environment(\.dismiss) private var dismiss
    @State private var marked = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("BgLight").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header verde ─────────────────────────────────────
                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Alerta sensor
                        if plant.hasSensor {
                            sensorBanner
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                        }

                        // Stats cards
                        statsSection
                            .padding(.horizontal, 20)
                            .padding(.top, plant.hasSensor ? 0 : 20)

                        // Cuidados programados
                        careSection
                            .padding(.horizontal, 20)

                        Spacer(minLength: 100)
                    }
                }
            }

            // ── Botón flotante ───────────────────────────────────────
            Button(action: { withAnimation { marked.toggle() } }) {
                HStack(spacing: 8) {
                    Image(systemName: marked ? "checkmark.circle.fill" : "drop.fill")
                    Text(marked ? "¡Regada! 💧" : "Marcar como regada")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(marked ? Color("StatusGreen") : Color("PlantDark"))
                .foregroundColor(Color("PlantCream"))
                .cornerRadius(50)
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .animation(.easeInOut(duration: 0.25), value: marked)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack {
            Color("PlantDark").ignoresSafeArea(edges: .top)

            VStack(spacing: 6) {
                // Back
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Mis plantas")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(Color("PlantMuted"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)

                Text(plant.emoji)
                    .font(.system(size: 52))
                    .padding(.top, 4)

                Text(plant.name)
                    .font(.custom("Georgia-Bold", size: 26))
                    .foregroundColor(Color("PlantCream"))

                Text(plant.location)
                    .font(.system(size: 13))
                    .foregroundColor(Color("PlantMuted"))
                    .padding(.bottom, 20)
            }
            .padding(.top, 12)
        }
    }

    // MARK: - Banner sensor

    private var sensorBanner: some View {
        HStack(spacing: 10) {
            Text("💧")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("Sensor IoT activo")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(plant.status == .seco ? "StatusRed" : "StatusGreen"))

                Text("Humedad: \(plant.humidity)% · \(plant.status == .seco ? "Tierra seca" : "Niveles normales")")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(14)
        .background(
            plant.status == .seco
                ? Color("StatusRed").opacity(0.08)
                : Color("StatusGreen").opacity(0.08)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    plant.status == .seco
                        ? Color("StatusRed").opacity(0.3)
                        : Color("StatusGreen").opacity(0.3),
                    lineWidth: 1
                )
        )
        .cornerRadius(14)
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 10) {
            if plant.hasSensor {
                StatDetail(
                    value: "\(Int(plant.temperature))°C",
                    label: "Temp",
                    icon: "thermometer.medium",
                    color: "StatusRed"
                )
                StatDetail(
                    value: "\(plant.humidity)%",
                    label: "Humedad",
                    icon: "drop.fill",
                    color: "StatusBlue"
                )
                StatDetail(
                    value: plant.light.rawValue,
                    label: "Luz",
                    icon: "sun.max.fill",
                    color: "StatusGreen"
                )
            }
            StatDetail(
                value: "\(plant.daysUntilWatering) días",
                label: "Riego",
                icon: "calendar",
                color: "PlantAccent"
            )
        }
    }

    // MARK: - Cuidados

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Cuidados programados")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color("TextDark"))

            CareRow(
                icon: "drop.fill",
                title: "Riego",
                detail: plant.wateringDays.map { $0.rawValue }.joined(separator: " / "),
                color: "StatusBlue"
            )

            Divider()

            CareRow(
                icon: "leaf.fill",
                title: "Fertilizante",
                detail: plant.fertilizingFrequency,
                color: "StatusGreen"
            )

            Divider()

            CareRow(
                icon: "sparkles",
                title: "Limpiar hojas",
                detail: plant.cleaningFrequency,
                color: "PlantAccent"
            )
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Subviews

private struct StatDetail: View {
    let value: String
    let label: String
    let icon: String
    let color: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(color))
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color("TextDark"))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private struct CareRow: View {
    let icon: String
    let title: String
    let detail: String
    let color: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(color))
                .font(.system(size: 15))
                .frame(width: 20)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("TextDark"))

            Spacer()

            Text(detail)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(plant: Plant(
            name: "Pothos Dorado",
            location: "Sala",
            status: .seco,
            hasSensor: true,
            emoji: "🪴",
            temperature: 22,
            humidity: 18,
            light: .media,
            wateringDays: [.lun, .mier, .vie],
            fertilizingFrequency: "Cada 15 días",
            cleaningFrequency: "Semanal",
            daysUntilWatering: 3
        ))
    }
}
