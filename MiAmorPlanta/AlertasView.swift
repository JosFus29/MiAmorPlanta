import SwiftUI

struct AlertasView: View {
    var body: some View {
        ZStack {
            Color("BgLight").ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color("PlantAccent").opacity(0.4))
                Text("Alertas")
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

#Preview { AlertasView() }
