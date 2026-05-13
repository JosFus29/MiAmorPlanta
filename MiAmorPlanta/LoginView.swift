import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var loginSuccess = false

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

                Text("Bienvenida")
                    .font(.custom("Georgia-Bold", size: 26))
                    .foregroundColor(Color("PlantCream"))

                Text("Inicia sesión para cuidar tus plantas")
                    .font(.system(size: 13))
                    .foregroundColor(Color("PlantMuted"))
                    .padding(.top, 4)
                    .padding(.bottom, 28)

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

                Button(action: handleLogin) {
                    Text("Entrar")
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
                    Text("¿No tienes cuenta?")
                        .font(.system(size: 13))
                        .foregroundColor(Color("PlantMuted"))
                    NavigationLink(destination: RegisterView()) {
                        Text("Regístrate aquí")
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
                        .background(toastMessage.contains("incorrectos") || toastMessage.contains("campos")
                                    ? Color.red.opacity(0.85)
                                    : Color("PlantAccent"))
                        .cornerRadius(20)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // Navega al Home tras login exitoso
            NavigationLink(destination: HomeView(), isActive: $loginSuccess) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: showToast)
    }

    // MARK: - Lógica

    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            toast("Llena todos los campos")
            return
        }

        if AccountStorage.shared.validate(email: email, password: password) {
            toast("¡Bienvenida de vuelta!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                loginSuccess = true
            }
        } else {
            toast("Correo o contraseña incorrectos")
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
    NavigationStack { LoginView() }
}
