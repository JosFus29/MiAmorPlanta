import SwiftUI

struct ContentView: View {
    // Conectamos la interfaz con el gestor de datos de Firebase
    @StateObject private var viewModel = PlantaViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Encabezado principal
                VStack(alignment: .leading, spacing: 6) {
                    Text("Monitoreo IoT")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("Mi Amor Planta")
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Tarjeta: Humedad del Suelo
                VStack(spacing: 16) {
                    HStack {
                        // CORRECCIÓN: Se usa systemImage en lugar de systemName
                        Label("Humedad del Suelo", systemImage: "drop.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(viewModel.humedadCruda)")
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                        Text("unidades")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Indicador de Estado de Humedad
                    Text(viewModel.estadoHumedad)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                
                // Tarjeta: Temperatura Ambiente
                VStack(spacing: 16) {
                    HStack {
                        // CORRECCIÓN: Se usa systemImage en lugar de systemName
                        Label("Temperatura", systemImage: "thermometer.medium")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(String(format: "%.1f", viewModel.temperatura))
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                        Text("°C")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Indicador de Estado de Temperatura
                    Text(viewModel.estadoTemperatura)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.12))
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// Vista previa para el Canvas de Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
