import SwiftUI

struct PlantTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color("PlantMuted"))
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
                    .stroke(Color("PlantBorder"), lineWidth: 1)
            )
            .foregroundColor(Color("PlantCream"))
            .font(.system(size: 14))
        }
    }
}

#Preview {
    ZStack {
        Color("PlantDark").ignoresSafeArea()
        PlantTextField(
            label: "Correo",
            placeholder: "hola@miplanta.com",
            text: .constant(""),
            isSecure: false
        )
        .padding()
    }
}
