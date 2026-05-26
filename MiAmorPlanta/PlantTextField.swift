import SwiftUI

struct PlantTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil   // nil = sin error

    var hasError: Bool { errorMessage != nil && !(errorMessage!.isEmpty) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(hasError ? Color.red.opacity(0.85) : Color("PlantMuted"))
                .kerning(0.5)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(label.lowercased().contains("correo") ? .emailAddress : .default)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(
                            label.lowercased().contains("correo") ? .never : .words
                        )
                }
            }
            .padding(12)
            .background(Color.black.opacity(0.25))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(hasError ? Color.red.opacity(0.85) : Color("PlantBorder"), lineWidth: hasError ? 1.5 : 1)
            )
            .foregroundColor(Color("PlantCream"))
            .font(.system(size: 14))

            // Mensaje de error inline
            if let msg = errorMessage, !msg.isEmpty {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 11))
                    Text(msg)
                        .font(.system(size: 12))
                }
                .foregroundColor(Color.red.opacity(0.85))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }
}

#Preview {
    ZStack {
        Color("PlantDark").ignoresSafeArea()
        VStack(spacing: 20) {
            PlantTextField(
                label: "Correo",
                placeholder: "hola@miplanta.com",
                text: .constant("mal@"),
                isSecure: false,
                errorMessage: "Correo no válido"
            )
            PlantTextField(
                label: "Contraseña",
                placeholder: "••••••••",
                text: .constant(""),
                isSecure: true,
                errorMessage: "Contraseña incorrecta"
            )
        }
        .padding()
    }
}
