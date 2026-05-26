import SwiftUI

struct EditPlantCareView: View {
    let plant: Plant
    @Environment(\.dismiss) private var dismiss

    @State private var selectedWateringDays: Set<WateringDay>
    @State private var selectedFertilizing: String
    @State private var selectedCleaning: String
    @State private var showToast = false

    private let fertilizingOptions = [
        "Cada semana",
        "Cada 15 días",
        "Cada mes",
        "Cada 2 meses",
        "No fertilizar"
    ]

    private let cleaningOptions = [
        "Diario",
        "Semanal",
        "Quincenal",
        "Mensual",
        "No limpiar"
    ]

    init(plant: Plant) {
        self.plant = plant
        _selectedWateringDays = State(initialValue: Set(plant.wateringDays))
        _selectedFertilizing  = State(initialValue: plant.fertilizingFrequency.isEmpty ? "Cada 15 días" : plant.fertilizingFrequency)
        _selectedCleaning     = State(initialValue: plant.cleaningFrequency.isEmpty    ? "Semanal"      : plant.cleaningFrequency)
    }

    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack {
                    Text("Editar cuidados")
                        .font(.custom("Georgia-Bold", size: 22))
                        .foregroundColor(Color("TextDark"))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // ── Días de riego ──────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("Días de riego")

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible()), count: 7),
                                spacing: 8
                            ) {
                                ForEach(WateringDay.allCases, id: \.self) { day in
                                    let selected = selectedWateringDays.contains(day)
                                    Button(action: {
                                        if selected {
                                            selectedWateringDays.remove(day)
                                        } else {
                                            selectedWateringDays.insert(day)
                                        }
                                    }) {
                                        Text(day.rawValue)
                                            .font(.system(size: 10, weight: .semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(selected ? Color("PlantAccent") : Color.white)
                                            .foregroundColor(selected ? .white : .gray)
                                            .cornerRadius(8)
                                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // ── Fertilizante ───────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Frecuencia de fertilizante")
                            pickerRow(options: fertilizingOptions, selected: $selectedFertilizing)
                        }
                        .padding(.horizontal, 24)

                        // ── Limpieza ───────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Limpieza de hojas")
                            pickerRow(options: cleaningOptions, selected: $selectedCleaning)
                        }
                        .padding(.horizontal, 24)

                        // ── Botón guardar ──────────────────────────
                        Button(action: handleSave) {
                            Text("Guardar cambios")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("PlantDark"))
                                .foregroundColor(Color("PlantCream"))
                                .cornerRadius(50)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }

            // Toast confirmación
            if showToast {
                VStack {
                    Spacer()
                    Text("✅ Cuidados actualizados")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color("PlantAccent"))
                        .cornerRadius(20)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showToast)
    }

    // MARK: - Guardar

    private func handleSave() {
        var updated = plant
        updated.wateringDays = Array(selectedWateringDays).sorted { a, b in
            let indexA = WateringDay.allCases.firstIndex(of: a) ?? 0
            let indexB = WateringDay.allCases.firstIndex(of: b) ?? 0
            return indexA < indexB
        }
        updated.fertilizingFrequency = selectedFertilizing
        updated.cleaningFrequency    = selectedCleaning

        PlantStorage.shared.update(updated)

        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }

    // MARK: - Componentes

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.gray)
            .kerning(0.4)
    }

    private func pickerRow(options: [String], selected: Binding<String>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: { selected.wrappedValue = option }) {
                        Text(option)
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selected.wrappedValue == option
                                        ? Color("PlantAccent")
                                        : Color.white)
                            .foregroundColor(selected.wrappedValue == option
                                             ? .white : .gray)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
            }
        }
    }
}

#Preview {
    EditPlantCareView(
        plant: Plant(
            name: "Pothos Dorado",
            location: "Sala",
            status: .bien,
            hasSensor: false,
            emoji: "🪴"
        )
    )
}
