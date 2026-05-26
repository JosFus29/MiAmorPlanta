import SwiftUI

struct SensoresView: View {
    @StateObject private var viewModel = PlantaViewModel(plantId: "")

    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()

            VStack(spacing: 0) {

                // Header
                ZStack {
                    Color("PlantDark").ignoresSafeArea(edges: .top)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sensores IoT")
                            .font(.custom("Georgia-Bold", size: 26))
                            .foregroundColor(Color("PlantCream"))
                        Text("Monitoreo en tiempo real")
                            .font(.system(size: 13))
                            .foregroundColor(Color("PlantMuted"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
                .frame(maxHeight: 110)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Tarjeta Humedad
                        sensorCard(
                            icon: "drop.fill",
                            iconColor: .blue,
                            title: "Humedad del Suelo",
                            value: viewModel.cargando ? "--" : "\(viewModel.humedadCruda)",
                            unit: "unidades",
                            estado: viewModel.estadoHumedad,
                            estadoColor: .blue
                        )

                        // Tarjeta Temperatura
                        sensorCard(
                            icon: "thermometer.medium",
                            iconColor: .orange,
                            title: "Temperatura Ambiente",
                            value: viewModel.cargando ? "--" : String(format: "%.1f", viewModel.temperatura),
                            unit: "°C",
                            estado: viewModel.estadoTemperatura,
                            estadoColor: .orange
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
                .onAppear {
                    if let firstId = PlantStorage.shared.plants
                        .first(where: { $0.hasSensor })?.id.uuidString {
                        viewModel.cambiarPlanta(plantId: firstId)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func sensorCard(
        icon: String,
        iconColor: Color,
        title: String,
        value: String,
        unit: String,
        estado: String,
        estadoColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(iconColor)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.cargando ? Color.gray : Color("StatusGreen"))
                        .frame(width: 10, height: 10)
                    Text(viewModel.cargando ? "Conectando..." : "En vivo")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(viewModel.cargando ? .gray : Color("StatusGreen"))
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(value)
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .foregroundColor(Color("TextDark"))
                Text(unit)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(estado)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(estadoColor.opacity(0.12))
                .foregroundColor(estadoColor)
                .cornerRadius(10)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    NavigationStack { SensoresView() }
}
