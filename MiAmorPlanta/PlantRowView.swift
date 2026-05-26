import SwiftUI

struct PlantRowView: View {
    let plant: Plant

    var body: some View {
        NavigationLink(destination: PlantDetailView(plant: plant)) {
            HStack(spacing: 14) {

                // Imagen real si viene de API, si no el emoji
                if let urlStr = plant.imageURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .empty:
                            ProgressView().tint(Color("PlantAccent"))
                        case .failure:
                            emojiPlaceholder
                        @unknown default:
                            emojiPlaceholder
                        }
                    }
                    .frame(width: 52, height: 52)
                    .background(Color("PlantAccent").opacity(0.12))
                    .cornerRadius(12)
                    .clipped()
                } else {
                    emojiPlaceholder
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(plant.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("TextDark"))

                        HStack(spacing: 3) {
                            Image(systemName: plant.status.icon)
                                .font(.system(size: 9))
                            Text(plant.status.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color(plant.status.color).opacity(0.15))
                        .foregroundColor(Color(plant.status.color))
                        .cornerRadius(20)
                    }

                    Text("\(plant.location)  ·  \(plant.hasSensor ? "Sensor IoT conectado" : "Sin sensor")")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(plant.status.color))
                            .frame(width: 6, height: 6)
                        Text(statusHint)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var emojiPlaceholder: some View {
        Text(plant.emoji)
            .font(.system(size: 32))
            .frame(width: 52, height: 52)
            .background(Color("PlantAccent").opacity(0.12))
            .cornerRadius(12)
    }

    private var statusHint: String {
        switch plant.status {
        case .seco:   return "Tierra seca · Regar ahora"
        case .bien:   return "Próximo riego: en \(plant.daysUntilWatering) días"
        case .pronto: return "Humedad: \(plant.humidity)% · Regar mañana"
        }
    }
}
