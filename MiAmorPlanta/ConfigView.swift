import SwiftUI
import UserNotifications

struct ConfigView: View {
    @State private var alertasSensor = true
    @State private var recordatoriosDiarios = true
    @State private var horaRecordatorio = ConfigView.loadSavedTime()
    @State private var showLogoutAlert = false
    @State private var showSavedToast = false
    @State private var toastMessage = ""
    @State private var notifPermission: UNAuthorizationStatus = .notDetermined
    @State private var showEditProfile = false
    @State private var showHistorial = false
    @AppStorage("sensor_threshold") private var umbralAlerta: Double = 20.0
    @State private var profileName: String = AccountStorage.shared.savedName
    @ObservedObject private var auth = AuthService.shared
    @State private var profileEmail: String = AuthService.shared.currentUser?.email ?? UserDefaults.standard.string(forKey: "account_email") ?? ""

    private var savedName: String { profileName }
    private var savedEmail: String { profileEmail }

    private var initials: String {
        let parts = savedName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Notificaciones
                        sectionCard(title: "Notificaciones") {
                            toggleRow(label: "Alertas del sensor", isOn: $alertasSensor)
                            Divider()
                            toggleRow(label: "Recordatorios diarios", isOn: $recordatoriosDiarios)

                            if recordatoriosDiarios {
                                Divider()
                                VStack(spacing: 10) {
                                    HStack {
                                        Text("Hora recordatorio")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color("TextDark"))
                                        Spacer()
                                        DatePicker("", selection: $horaRecordatorio,
                                                   displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .tint(Color("PlantAccent"))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)

                                    if notifPermission == .denied {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 12))
                                            Text("Notificaciones bloqueadas. Ve a Ajustes > Mi Amor Planta > Notificaciones y actívalas.")
                                                .font(.system(size: 12))
                                                .foregroundColor(.orange)
                                        }
                                        .padding(.horizontal, 16)
                                    }

                                    Button(action: guardarHora) {
                                        Text("Guardar hora")
                                            .font(.system(size: 14, weight: .semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(notifPermission == .denied
                                                        ? Color.gray
                                                        : Color("PlantAccent"))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 10)
                                    .disabled(notifPermission == .denied)
                                }
                            }
                        }

                        // Sensores IoT
                        sectionCard(title: "Sensores IoT") {
                            thresholdRow(label: "Umbral de alerta", value: $umbralAlerta)
                            Divider()
                            infoRow(label: "Frecuencia lecturas", value: "30 min")
                        }

                        // Cuenta
                        sectionCard(title: "Cuenta") {
                            Button(action: { showEditProfile = true }) {
                                arrowRow(label: "Editar perfil")
                            }
                            Divider()
                            Button(action: { showHistorial = true }) {
                                arrowRow(label: "Historial", icon: "clock.arrow.circlepath")
                            }
                        }

                        // Cerrar sesión
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

            // Toast
            if showSavedToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
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
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: showSavedToast)
        .onAppear {
            checkNotifPermission()
            profileName  = auth.currentUser?.displayName ?? AccountStorage.shared.savedName
            profileEmail = auth.currentUser?.email ?? UserDefaults.standard.string(forKey: "account_email") ?? ""
        }
        .alert("¿Cerrar sesión?", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar sesión", role: .destructive) {
                AuthService.shared.logout()
            }
        } message: {
            Text("Se borrará la sesión guardada.")
        }
        .sheet(isPresented: $showEditProfile, onDismiss: {
            profileName  = AccountStorage.shared.savedName
            profileEmail = AuthService.shared.currentUser?.email ?? UserDefaults.standard.string(forKey: "account_email") ?? ""
        }) {
            EditProfileSheet()
        }
        .sheet(isPresented: $showHistorial) {
            HistorialSheet()
        }
    }

    // MARK: - Guardar hora

    private func guardarHora() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: horaRecordatorio)
        let hour   = components.hour   ?? 8
        let minute = components.minute ?? 0

        UserDefaults.standard.set(hour,   forKey: "notif_hour")
        UserDefaults.standard.set(minute, forKey: "notif_minute")

        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    scheduleNotification(hour: hour, minute: minute, center: center)
                    showToast("✅ Recordatorio guardado para las \(formattedTime(hour: hour, minute: minute))")

                case .notDetermined:
                    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            checkNotifPermission()
                            if granted {
                                scheduleNotification(hour: hour, minute: minute, center: center)
                                showToast("✅ Recordatorio guardado para las \(formattedTime(hour: hour, minute: minute))")
                            } else {
                                showToast("⚠️ Permiso denegado, actívalo en Ajustes")
                            }
                        }
                    }

                case .denied:
                    showToast("⚠️ Activa las notificaciones en Ajustes del iPhone")

                @unknown default:
                    break
                }
            }
        }
    }

    private func scheduleNotification(hour: Int, minute: Int, center: UNUserNotificationCenter) {
        center.removePendingNotificationRequests(withIdentifiers: ["watering_daily"])

        let plants  = PlantStorage.shared.plants
        let today   = Calendar.current.component(.weekday, from: Date())
        let weekdayMap: [Int: WateringDay] = [
            1: .dom, 2: .lun, 3: .mar,
            4: .mier, 5: .jue, 6: .vie, 7: .sab
        ]
        let todayEnum = weekdayMap[today]

        let plantasHoy = plants.filter { plant in
            guard let todayEnum else { return false }
            return plant.wateringDays.contains(todayEnum)
        }

        let content = UNMutableNotificationContent()
        content.title = "🌿 Mi Amor Planta"
        content.sound = .default

        if plantasHoy.isEmpty {
            content.body = "Recuerda revisar tus plantas hoy 💚"
        } else if plantasHoy.count == 1 {
            content.body = "Hoy le toca riego a \(plantasHoy[0].name) \(plantasHoy[0].emoji)"
        } else {
            let nombres = plantasHoy.map { "\($0.emoji) \($0.name)" }.joined(separator: ", ")
            content.body = "Hoy riegan: \(nombres)"
        }

        var trigger = DateComponents()
        trigger.hour   = hour
        trigger.minute = minute

        let request = UNNotificationRequest(
            identifier: "watering_daily",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        center.add(request) { error in
            if let error { print("Error al programar notificación: \(error)") }
        }
    }

    // MARK: - Helpers

    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation { showSavedToast = false }
        }
    }

    private func formattedTime(hour: Int, minute: Int) -> String {
        String(format: "%d:%02d %@", hour > 12 ? hour - 12 : hour,
               minute, hour >= 12 ? "pm" : "am")
    }

    private func checkNotifPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notifPermission = settings.authorizationStatus
            }
        }
    }

    static func loadSavedTime() -> Date {
        let hour   = UserDefaults.standard.integer(forKey: "notif_hour")
        let minute = UserDefaults.standard.integer(forKey: "notif_minute")
        var comps  = DateComponents()
        comps.hour   = (hour == 0 && minute == 0) ? 8 : hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
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

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color("PlantAccent"))
                            .frame(width: 52, height: 52)
                        Text(initials.isEmpty ? "?" : initials)
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

    private func thresholdRow(label: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextDark"))
                Spacer()
                Text("<\(Int(value.wrappedValue))% humedad")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("PlantAccent"))
            }
            Slider(value: value, in: 5...50, step: 1)
                .tint(Color("PlantAccent"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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

// MARK: - EditProfileSheet

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var nombre: String = ""
    @State private var email: String = ""
    @State private var showSaved = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BgLight").ignoresSafeArea()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color("PlantAccent").opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color("PlantAccent"))
                    }
                    .padding(.top, 10)

                    VStack(spacing: 0) {
                        fieldRow(icon: "person", label: "Nombre", text: $nombre)
                        Divider().padding(.leading, 48)
                        fieldRow(icon: "envelope", label: "Correo", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 20)

                    if showSaved {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color("PlantAccent"))
                            Text("Cambios guardados")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("PlantAccent"))
                        }
                        .transition(.opacity)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(Color("PlantAccent"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { guardar() }
                        .foregroundColor(Color("PlantDark"))
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            nombre = AccountStorage.shared.savedName
            email  = UserDefaults.standard.string(forKey: "account_email") ?? ""
        }
    }

    private func fieldRow(icon: String, label: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color("PlantAccent"))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                TextField(label, text: text)
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextDark"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func guardar() {
        let password = UserDefaults.standard.string(forKey: "account_password") ?? ""
        AccountStorage.shared.save(name: nombre, email: email, password: password)
        withAnimation { showSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
    }
}

// MARK: - HistorialSheet

struct HistorialSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storage = PlantStorage.shared

    private var historial: [(emoji: String, nombre: String, accion: String, fecha: String)] {
        var items: [(emoji: String, nombre: String, accion: String, fecha: String)] = []
        for plant in storage.plants {
            if plant.status == .bien {
                items.append((plant.emoji, plant.name, "Regada", "Hoy"))
            }
            if !plant.fertilizingFrequency.isEmpty {
                items.append((plant.emoji, plant.name, "Fertilizada", "Hace 3 días"))
            }
            if !plant.cleaningFrequency.isEmpty {
                items.append((plant.emoji, plant.name, "Limpieza de hojas", "Hace 1 semana"))
            }
        }
        return items
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BgLight").ignoresSafeArea()

                if historial.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(Color("PlantAccent").opacity(0.4))
                        Text("Sin historial todavía")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("TextDark"))
                        Text("Aquí verás el registro de cuidados\nde todas tus plantas")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(Array(historial.enumerated()), id: \.offset) { _, item in
                                HStack(spacing: 14) {
                                    Text(item.emoji)
                                        .font(.system(size: 28))
                                        .frame(width: 44, height: 44)
                                        .background(Color("PlantAccent").opacity(0.1))
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.nombre)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color("TextDark"))
                                        Text(item.accion)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Text(item.fecha)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color("PlantAccent"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                        .foregroundColor(Color("PlantDark"))
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ConfigView() }
}
