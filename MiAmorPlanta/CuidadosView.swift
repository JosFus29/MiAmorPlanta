import SwiftUI

struct CuidadosView: View {

    @ObservedObject private var storage = PlantStorage.shared
    @StateObject private var sensorVM = PlantaViewModel(plantId: "")
    
    @State private var showAddSensor = false

    private var withSensor: [Plant] {
        storage.plants.filter { $0.hasSensor }
    }

    private var withoutSensor: [Plant] {
        storage.plants.filter { !$0.hasSensor }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("BgLight").ignoresSafeArea()

            VStack(spacing: 0) {

                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {

                        if storage.plants.isEmpty {
                            emptyState
                                .padding(.top, 60)
                        } else {

                            // Tarjeta resumen en vivo
                            if !withSensor.isEmpty {
                                liveDataCard
                                    .onAppear {
                                        if let firstId = withSensor.first?.id.uuidString {
                                            sensorVM.cambiarPlanta(plantId: firstId)
                                        }
                                    }
                            }

                            // Plantas con sensor
                            ForEach(withSensor) { plant in
                                SensorCardView(plant: plant/*, sensorVM: sensorVM*/)
                            }

                            // Plantas sin sensor
                            if !withoutSensor.isEmpty {
                                noSensorBanner
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }

            // Botón flotante
            Button(action: { showAddSensor = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                    Text("Agregar nuevo sensor")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(Color("PlantDark"))
                .cornerRadius(50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color("PlantBorder"), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .navigationBarHidden(true)
        .alert("Próximamente", isPresented: $showAddSensor) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("La integración con sensores IoT estará disponible en la siguiente versión.")
        }
    }

    // MARK: - Tarjeta en vivo

    private var liveDataCard: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(sensorVM.cargando ? Color.gray : Color("StatusGreen"))
                        .frame(width: 8, height: 8)
                    Text(sensorVM.cargando ? "Conectando..." : "Datos en vivo · ESP32")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(sensorVM.cargando ? .gray : Color("StatusGreen"))
                }
                Spacer()
                Text("Actualización automática")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }

            HStack(spacing: 10) {
                // Humedad
                VStack(spacing: 6) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                    Text(sensorVM.cargando ? "--" : "\(sensorVM.humedadCruda)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("TextDark"))
                    Text("Humedad")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text(sensorVM.estadoHumedad)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue.opacity(0.06))
                .cornerRadius(14)

                // Temperatura
                VStack(spacing: 6) {
                    Image(systemName: "thermometer.medium")
                        .font(.system(size: 18))
                        .foregroundColor(.orange)
                    Text(sensorVM.cargando ? "--" : String(format: "%.1f°", sensorVM.temperatura))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("TextDark"))
                    Text("Temperatura")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text(sensorVM.estadoTemperatura)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.orange.opacity(0.06))
                .cornerRadius(14)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack {
            Color("PlantDark").ignoresSafeArea(edges: .top)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("Más Cuidados")
                        .font(.custom("Georgia-Bold", size: 22))
                        .foregroundColor(Color("PlantCream"))

                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color("PlantAccent"))
                        .font(.system(size: 13))
                }

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color("StatusGreen"))
                        .frame(width: 6, height: 6)
                    Text("\(withSensor.count) activo\(withSensor.count == 1 ? "" : "s")")
                        .font(.system(size: 11))
                        .foregroundColor(Color("PlantMuted"))

                    Text("•")
                        .foregroundColor(Color("PlantMuted"))

                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 6, height: 6)
                    Text("\(withoutSensor.count) sin señal")
                        .font(.system(size: 11))
                        .foregroundColor(Color("PlantMuted"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
        .frame(maxHeight: 200)
    }

    // MARK: - Sin plantas

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                .font(.system(size: 48))
                .foregroundColor(Color("PlantAccent").opacity(0.4))

            Text("Sin sensores activos")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("TextDark"))

            Text("Agrega plantas con sensor IoT\npara verlas aquí")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Banner sin sensor

    private var noSensorBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sin sensor asignado")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .kerning(0.4)

            ForEach(withoutSensor) { plant in
                HStack(spacing: 12) {
                    Text(plant.emoji)
                        .font(.system(size: 24))
                        .frame(width: 42, height: 42)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(plant.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("TextDark"))
                        Text("\(plant.location) · Sin sensor")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("Conectar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("PlantAccent"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("PlantAccent").opacity(0.1))
                        .cornerRadius(20)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
            }
        }
    }
}

#Preview {
    NavigationStack { CuidadosView() }
}
