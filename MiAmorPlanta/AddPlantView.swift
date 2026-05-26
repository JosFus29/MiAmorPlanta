import SwiftUI

struct AddPlantView: View {
    @Environment(\.dismiss) private var dismiss

    // Datos básicos
    @State private var name = ""
    @State private var location = ""
    @State private var hasSensor = false
    @State private var selectedStatus: PlantStatus = .bien
    @State private var selectedEmoji = "🪴"

    // Cuidados — el usuario los define
    @State private var selectedWateringDays: Set<WateringDay> = []
    @State private var selectedFertilizing: String = "Cada 15 días"
    @State private var selectedCleaning: String = "Semanal"

    // UI
    @State private var showToast = false
    @State private var toastError = false

    private let emojis = ["🪴", "🌵", "🌺", "🌸", "🌿", "🍀", "🌱", "🌾", "🌻", "🌹"]

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

    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack {
                    Text("Nueva planta")
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
                    VStack(alignment: .leading, spacing: 22) {

                        // ── Emoji ────────────────────────────────────
                        sectionLabel("Elige un ícono")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(emojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.system(size: 28))
                                        .frame(width: 52, height: 52)
                                        .background(selectedEmoji == emoji
                                                    ? Color("PlantAccent").opacity(0.2)
                                                    : Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedEmoji == emoji
                                                        ? Color("PlantAccent")
                                                        : Color.clear, lineWidth: 1.5)
                                        )
                                        .onTapGesture { selectedEmoji = emoji }
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        // ── Nombre ───────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Nombre de la planta")
                            PlantTextField(
                                label: "",
                                placeholder: "Ej. Pothos Dorado",
                                text: $name,
                                isSecure: false
                            )
                        }
                        .padding(.horizontal, 24)

                        // ── Ubicación ────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Ubicación")
                            PlantTextField(
                                label: "",
                                placeholder: "Ej. Sala, Recámara, Ventana…",
                                text: $location,
                                isSecure: false
                            )
                        }
                        .padding(.horizontal, 24)

                        // ── Estado ───────────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("Estado actual")
                            HStack(spacing: 10) {
                                ForEach(PlantStatus.allCases, id: \.self) { status in
                                    Button(action: { selectedStatus = status }) {
                                        Text(status.rawValue)
                                            .font(.system(size: 13, weight: .semibold))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedStatus == status
                                                        ? Color(status.color)
                                                        : Color.white)
                                            .foregroundColor(selectedStatus == status
                                                             ? .white : .gray)
                                            .cornerRadius(20)
                                            .shadow(color: .black.opacity(0.06),
                                                    radius: 3, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // ── Sensor ───────────────────────────────────
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sensor IoT conectado")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color("TextDark"))
                                Text("Activa si tienes un sensor físico")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Toggle("", isOn: $hasSensor)
                                .tint(Color("PlantAccent"))
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 24)

                        // ── Días de riego ────────────────────────────
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
                                            .background(selected
                                                        ? Color("PlantAccent")
                                                        : Color.white)
                                            .foregroundColor(selected ? .white : .gray)
                                            .cornerRadius(8)
                                            .shadow(color: .black.opacity(0.05),
                                                    radius: 2, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // ── Fertilizante ─────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Frecuencia de fertilizante")
                            pickerRow(
                                options: fertilizingOptions,
                                selected: $selectedFertilizing
                            )
                        }
                        .padding(.horizontal, 24)

                        // ── Limpieza ─────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Limpieza de hojas")
                            pickerRow(
                                options: cleaningOptions,
                                selected: $selectedCleaning
                            )
                        }
                        .padding(.horizontal, 24)

                        // ── Botón guardar ────────────────────────────
                        Button(action: handleSave) {
                            Text("Guardar planta")
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

            // Toast
            if showToast {
                VStack {
                    Spacer()
                    Text(toastError ? "Completa nombre y ubicación" : "¡Planta agregada! 🌱")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(toastError ? Color.red.opacity(0.85) : Color("PlantAccent"))
                        .cornerRadius(20)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showToast)
    }

    // MARK: - Componentes reutilizables

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

    // MARK: - Guardar

    private func handleSave() {
        guard !name.isEmpty, !location.isEmpty else {
            toastError = true
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation { showToast = false }
            }
            return
        }

        let plant = Plant(
            name: name,
            location: location,
            status: selectedStatus,
            hasSensor: hasSensor,
            emoji: selectedEmoji,
            temperature: 22.0,
            humidity: 50,
            light: .media,
            wateringDays: Array(selectedWateringDays).sorted { a, b in
                let indexA = WateringDay.allCases.firstIndex(of: a) ?? 0
                let indexB = WateringDay.allCases.firstIndex(of: b) ?? 0
                return indexA < indexB
            },
            fertilizingFrequency: selectedFertilizing,
            cleaningFrequency: selectedCleaning,
            daysUntilWatering: 0
        )

        PlantStorage.shared.add(plant)

        toastError = false
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}

#Preview {
    AddPlantView()
}
