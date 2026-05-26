import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var auth = AuthService.shared

    @State private var email = ""
    @State private var password = ""

    // Errores por campo
    @State private var emailError: String?    = nil
    @State private var passwordError: String? = nil

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
                    isSecure: false,
                    errorMessage: emailError
                )
                .padding(.bottom, 16)
                .onChange(of: email) { _ in emailError = nil }

                PlantTextField(
                    label: "Contraseña",
                    placeholder: "••••••••",
                    text: $password,
                    isSecure: true,
                    errorMessage: passwordError
                )
                .padding(.bottom, 28)
                .onChange(of: password) { _ in passwordError = nil }

                Button(action: handleLogin) {
                    Group {
                        if auth.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Entrar")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("PlantAccent"))
                    .foregroundColor(.white)
                    .cornerRadius(50)
                }
                .disabled(auth.isLoading)

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
        }
        .navigationBarHidden(true)
    }

    // MARK: - Lógica

    private func handleLogin() {
        emailError    = nil
        passwordError = nil

        // Validaciones locales primero
        guard !email.isEmpty else {
            emailError = "Ingresa tu correo"
            return
        }
        guard email.contains("@") else {
            emailError = "El correo no tiene un formato válido"
            return
        }
        guard !password.isEmpty else {
            passwordError = "Ingresa tu contraseña"
            return
        }

        auth.login(email: email, password: password) { success in
            if !success {
                mapFirebaseError(auth.errorMessage)
            }
        }
    }

    /// Traduce el error de Firebase al campo correcto
    private func mapFirebaseError(_ message: String) {
        let msg = message.lowercased()
        if msg.contains("correo") || msg.contains("existe") || msg.contains("válido") {
            emailError = message
        } else if msg.contains("contraseña") || msg.contains("incorrecta") {
            passwordError = message
        } else {
            // Error genérico: lo ponemos en correo
            emailError = message
        }
    }
}

#Preview {
    NavigationStack { LoginView() }
}
