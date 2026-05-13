import SwiftUI

struct HomeView: View {

    @StateObject private var storage = PlantStorage.shared
    @State private var showAddPlant = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:  return "BUENOS DÍAS"
        case 12..<18: return "BUENAS TARDES"
        default:      return "BUENAS NOCHES"
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("BgLight").ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        if storage.needWaterCount > 0 {
                            sensorAlert
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }

                        statsRow
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        plantsSection
                            .padding(.horizontal, 16)
                            .padding(.top, 20)

                        Spacer(minLength: 90)
                    }
                }
            }

            addButton
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddPlant) {
            AddPlantView()
        }
    }

    // MARK: - Header  ← más compacto

    private var headerSection: some View {
        ZStack {
            Color("PlantDark").ignoresSafeArea(edges: .top)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(greeting)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color("PlantMuted"))
                        .kerning(1)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("Mis Plantas")
                            .font(.custom("Georgia-Bold", size: 22))
                            .foregroundColor(Color("PlantCream"))

                        Image(systemName: "leaf.fill")
                            .foregroundColor(Color("PlantAccent"))
                            .font(.system(size: 13))
                    }

                    Text(storage.plants.isEmpty
                         ? "Agrega tu primera planta 🌱"
                         : "\(storage.needWaterCount) planta(s) necesitan atención hoy")
                        .font(.system(size: 11))
                        .foregroundColor(Color("PlantMuted"))
                }

                Spacer()

                Circle()
                    .fill(Color("PlantAccent").opacity(0.3))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(Color("PlantAccent"))
                            .font(.system(size: 15))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
        .frame(maxHeight: 200)
    }

    // MARK: - Alerta sensor

    private var sensorAlert: some View {
        HStack(spacing: 12) {
            Image(systemName: "drop.fill")
                .foregroundColor(.white)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 1) {
                Text("Sensor detectó: tierra seca")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Text(storage.plants.first(where: { $0.status == .seco })?.name ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Text("¡Regar!")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color("PlantDark"))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color("PlantCream"))
                .cornerRadius(20)
        }
        .padding(12)
        .background(Color("PlantAccent"))
        .cornerRadius(14)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatCard(value: "\(storage.plants.count)",    label: "Plantas\nregistradas")
            StatCard(value: "\(storage.needWaterCount)",  label: "Necesitan\nagua hoy")
            StatCard(value: "\(storage.activeSensors)",   label: "Sensores\nactivos")
        }
    }

    // MARK: - Plantas

    private var plantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mis plantas")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("TextDark"))
                Spacer()
                if !storage.plants.isEmpty {
                    Button("Ver todas →") {}
                        .font(.system(size: 13))
                        .foregroundColor(Color("PlantAccent"))
                }
            }

            if storage.plants.isEmpty {
                emptyState
            } else {
                ForEach(storage.plants) { plant in
                    PlantRowView(plant: plant)
                }
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf")
                .font(.system(size: 44))
                .foregroundColor(Color("PlantAccent").opacity(0.4))

            Text("Aún no tienes planta")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("TextDark"))

            Text("Toca el botón de abajo para\nagregar tu primera planta 🌱")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Botón agregar

    private var addButton: some View {
        Button(action: { showAddPlant = true }) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
                Text("Agregar nueva planta")
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color("PlantDark"))
            .foregroundColor(Color("PlantCream"))
            .cornerRadius(50)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}

private struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("TextDark"))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack { HomeView() }
}
