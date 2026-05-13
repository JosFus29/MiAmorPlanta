import SwiftUI

struct AddPlantView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var location = ""
    @State private var hasSensor = false
    @State private var selectedStatus: PlantStatus = .bien
    @State private var selectedEmoji = "🪴"
    @State private var showToast = false

    private let emojis = ["🪴", "🌵", "🌺", "🌸", "🌿", "🍀", "🌱", "🌾", "🌻", "🌹"]

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
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // Selección emoji
                        VStack(alignment: .leading, spacing: 10) {
                            fieldLabel("Elige un ícono")
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
                        }

                        // Nombre
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Nombre de la planta")
                            PlantTextField(
                                label: "",
                                placeholder: "Ej. Pothos Dorado",
                                text: $name,
                                isSecure: false
                            )
                        }
                        .padding(.horizontal, 24)

                        // Ubicación
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Ubicación")
                            PlantTextField(
                                label: "",
                                placeholder: "Ej. Sala, Recámara, Ventana…",
                                text: $location,
                                isSecure: false
                            )
                        }
                        .padding(.horizontal, 24)

                        // Estado
                        VStack(alignment: .leading, spacing: 10) {
                            fieldLabel("Estado actual")
                                .padding(.horizontal, 24)

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
                                                             ? .white
                                                             : .gray)
                                            .cornerRadius(20)
                                            .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        // Sensor toggle
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

                        // Botón guardar
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
                        .padding(.bottom, 32)
                    }
                }
            }

            // Toast
            if showToast {
                VStack {
                    Spacer()
                    Text("¡Planta agregada! 🌱")
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

    // MARK: - Helpers

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.gray)
            .textCase(.uppercase)
            .kerning(0.4)
    }

    private func handleSave() {
        guard !name.isEmpty, !location.isEmpty else { return }

        let plant = Plant(
            name: name,
            location: location,
            status: selectedStatus,
            hasSensor: hasSensor,
            emoji: selectedEmoji,
            temperature: 22.0,
            humidity: 60,
            light: .media,
            wateringDays: [.lun, .mier, .vie],
            fertilizingFrequency: "Cada 15 días",
            cleaningFrequency: "Semanal",
            daysUntilWatering: 3
        )

        PlantStorage.shared.add(plant)

        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}

#Preview {
    AddPlantView()
}
