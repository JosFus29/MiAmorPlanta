import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var registerSuccess = false

    var body: some View {
        ZStack {
            Color("PlantDark").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Volver")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color("PlantMuted"))
                }
                .padding(.bottom, 24)

                Text("Únete 🌱")
                    .font(.custom("Georgia-Bold", size: 26))
                    .foregroundColor(Color("PlantCream"))

                Text("Crea tu cuenta y empieza a cuidarlas")
                    .font(.system(size: 13))
                    .foregroundColor(Color("PlantMuted"))
                    .padding(.top, 4)
                    .padding(.bottom, 28)

                PlantTextField(
                    label: "Nombre completo",
                    placeholder: "Ana García López",
                    text: $fullName,
                    isSecure: false
                )
                .padding(.bottom, 16)

                PlantTextField(
                    label: "Correo",
                    placeholder: "hola@miplanta.com",
                    text: $email,
                    isSecure: false
                )
                .padding(.bottom, 16)

                PlantTextField(
                    label: "Contraseña",
                    placeholder: "••••••••",
                    text: $password,
                    isSecure: true
                )
                .padding(.bottom, 28)

                Button(action: handleRegister) {
                    Text("Crear cuenta")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PlantAccent"))
                        .foregroundColor(.white)
                        .cornerRadius(50)
                        .font(.system(size: 16, weight: .semibold))
                }

                Divider()
                    .background(Color("PlantBorder"))
                    .padding(.vertical, 20)

                HStack {
                    Spacer()
                    Text("¿Ya tienes cuenta?")
                        .font(.system(size: 13))
                        .foregroundColor(Color("PlantMuted"))
                    NavigationLink(destination: LoginView()) {
                        Text("Inicia sesión")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color("PlantAccent"))
                            .underline()
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)

            // Toast
            if showToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(toastMessage.contains("campos")
                                    ? Color.red.opacity(0.85)
                                    : Color("PlantAccent"))
                        .cornerRadius(20)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // Navega al Login tras registro exitoso
            NavigationLink(destination: LoginView(), isActive: $registerSuccess) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: showToast)
    }

    // MARK: - Lógica

    private func handleRegister() {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else {
            toast("Completa todos los campos")
            return
        }

        // Guardar en UserDefaults
        AccountStorage.shared.save(name: fullName, email: email, password: password)

        toast("¡Cuenta creada! Inicia sesión 🌱")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            registerSuccess = true
        }
    }

    private func toast(_ message: String) {
        toastMessage = message
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { showToast = false }
        }
    }
}

#Preview {
    NavigationStack { RegisterView() }
}
