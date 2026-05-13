//
//  SplashView.swift
//  MiAmorPlanta
//
//  Created by Alumno on 06/05/26.
//

import SwiftUI

struct SplashView: View {

    var body: some View {
        NavigationStack {
            ZStack {
                Color("PlantDark").ignoresSafeArea()

                VStack(spacing: 16) {
                    Spacer()

                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color("PlantAccent"))

                    Text("Mi Amor Planta")
                        .font(.custom("Georgia-Bold", size: 32))
                        .foregroundColor(Color("PlantCream"))

                    Text("El cuidado que necesitabas")
                        .font(.system(size: 15))
                        .italic()
                        .foregroundColor(Color("PlantMuted"))

                    Spacer()

                    NavigationLink(destination: LoginView()) {
                        Text("Iniciar sesión")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("PlantAccent"))
                            .foregroundColor(.white)
                            .cornerRadius(50)
                            .font(.system(size: 16, weight: .semibold))
                    }

                    NavigationLink(destination: RegisterView()) {
                        Text("Registrarse")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(Color("PlantMuted"))
                            .cornerRadius(50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color("PlantBorder"), lineWidth: 1.5)
                            )
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SplashView()
}
