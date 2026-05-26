import SwiftUI

struct ConfigView: View {
    @State private var alertasSensor = true
    @State private var recordatoriosDiarios = true
    @State private var horaRecordatorio = Date()
    @State private var showLogoutAlert = false
    @State private var showEditProfile = false

    private var savedName: String { AccountStorage.shared.savedName }
    private var savedEmail: String {
        UserDefaults.standard.string(forKey: "account_email") ?? ""
    }

    private var initials: String {
        let parts = savedName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ───────────────────────────────────────────
                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Notificaciones
                        sectionCard(title: "Notificaciones") {
                            toggleRow(label: "Alertas del sensor", isOn: $alertasSensor)
                            Divider()
                            toggleRow(label: "Recordatorios diarios", isOn: $recordatoriosDiarios)
                            Divider()
                            timeRow(label: "Hora recordatorio", date: $horaRecordatorio)
                        }

                        // Sensores IoT
                        sectionCard(title: "Sensores IoT") {
                            infoRow(label: "Alertas del sensor", value: "<20% alerta")
                            Divider()
                            infoRow(label: "Frecuencia lecturas", value: "30 min")
                        }

                        // Cuenta
                        sectionCard(title: "Cuenta") {
                            Button(action: { showEditProfile = true }) {
                                arrowRow(label: "Editar perfil")
                            }
                            Divider()
                            Button(action: {}) {
                                arrowRow(label: "Historial", icon: "ellipsis")
                            }
                        }

                        // Botón cerrar sesión
                        Button(action: { showLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Cerrar sesión")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(Color("StatusRed"))
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
    
        .navigationBarHidden(true)
        .alert("¿Cerrar sesión?", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar sesión", role: .destructive) {
                AuthService.shared.logout()
            }
        } message: {
            Text("Se borrará la sesión guardada.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack {
            Color("PlantDark").ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                Text("Configuración")
                    .font(.custom("Georgia-Bold", size: 24))
                    .foregroundColor(Color("PlantCream"))
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                // Tarjeta de perfil
                HStack(spacing: 14) {
                    // Iniciales
                    ZStack {
                        Circle()
                            .fill(Color("PlantAccent"))
                            .frame(width: 52, height: 52)
                        Text(initials)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(savedName.isEmpty ? "Usuario" : savedName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color("PlantCream"))
                        Text(savedEmail.isEmpty ? "sin correo" : savedEmail)
                            .font(.system(size: 13))
                            .foregroundColor(Color("PlantMuted"))
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxHeight: 200)
    }

    // MARK: - Helpers de secciones

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color("PlantAccent"))
                .underline()
                .padding(.bottom, 10)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
    }

    private func toggleRow(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("TextDark"))
            Spacer()
            Toggle("", isOn: isOn)
                .tint(Color("PlantAccent"))
                .labelsHidden()
                .scaleEffect(0.85)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("TextDark"))
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(Color("PlantAccent"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func timeRow(label: String, date: Binding<Date>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("TextDark"))
            Spacer()
            DatePicker("", selection: date, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .tint(Color("PlantAccent"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private func arrowRow(label: String, icon: String = "arrow.right") -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("TextDark"))
            Spacer()
            Image(systemName: icon)
                .foregroundColor(Color("PlantAccent"))
                .font(.system(size: 14))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack { ConfigView() }
}
