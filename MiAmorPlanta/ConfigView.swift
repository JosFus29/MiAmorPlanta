import SwiftUI

struct ConfigView: View {
    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color("PlantAccent").opacity(0.4))
                Text("Configuración")
                    .font(.custom("Georgia-Bold", size: 22))
                    .foregroundColor(Color("TextDark"))
                Text("Próximamente")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview { ConfigView() }
