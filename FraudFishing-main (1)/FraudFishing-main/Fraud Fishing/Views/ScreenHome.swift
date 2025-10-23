//
//  ScreenHome.swift
//  Fraud Fishing
//
//  Created by Javier Canella Ramos on 22/09/25.
//

import SwiftUI

struct ScreenHome: View {
    @State private var urlInput: String = ""
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var authController: AuthenticationController

    var body: some View {
        ZStack(alignment: .bottom) {
            // Capa 1: Contenido principal con fondo
            ZStack(alignment: .topTrailing) {
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)]),
                               startPoint: UnitPoint(x:0.5, y:0.1),
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Header con logo y botón de perfil
                    HStack {
                        Spacer()
                        
                    // Logo
                    Image("LogoBlanco")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 400, height: 240)
                        .padding(.top, 60)
                        
                        Spacer()
                    }

                    // Barra de entrada de URL
                    HStack {
                        TextField("URL", text: $urlInput)
                            .padding()
                            .background(Color(red: 0.0, green: 0.71, blue: 0.737, opacity: 0.2))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(red: 0.0, green: 0.71, blue: 0.737))
                            )
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                    .padding(.bottom, 30)

                    // Botones de Reportar y Buscar
                    HStack(spacing: 20) {
                        NavigationLink(destination: ScreenCreateReport(reportedURL: urlInput)) {
                            Text("Reportar")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }

                        NavigationLink(destination: ScreenBuscar(searchedURL: urlInput).environmentObject(authController)) {
                            Text("Buscar")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.0, green: 0.71, blue: 0.737))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)

                    Spacer()
                }
                .padding(.bottom, 88) // Espacio para la tab bar

                // Botón de notificaciones
                NavigationLink(destination: ScreenNotifications().environmentObject(authController)) {
                    Image(systemName: "bell.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 0.0, green: 0.71, blue: 0.737))
                        .overlay(
                            Text("1")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 10, y: -10)
                        )
                }
                .padding(.trailing, 30)
                .padding(.top, 20)
            }
            // Capa 2: CustomTabBar superpuesta
            CustomTabBar(selectedTab: $selectedTab).environmentObject(authController)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .edgesIgnoringSafeArea(.bottom)
    }
}

enum Tab {
    case home, dashboard, profile, settings
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject var authController: AuthenticationController

    var body: some View {
        let turquoise = Color(red: 0.0, green: 0.71, blue: 0.737)
        let barHeight: CGFloat = 88

        ZStack {
            // Fondo blanco con curva hacia abajo al centro
            Path { path in
                let width = UIScreen.main.bounds.width
                path.move(to: CGPoint(x: -20, y: 0)) // <- sobresale un poco a la izquierda
                path.addQuadCurve(to: CGPoint(x: width + 20, y: 0), // <- sobresale a la derecha
                                  control: CGPoint(x: width / 2, y: 40))
                path.addLine(to: CGPoint(x: width + 20, y: barHeight))
                path.addLine(to: CGPoint(x: -20, y: barHeight))
                path.closeSubpath()

            }
            .fill(Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.6))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: -6)

            // Laterales: Dashboard y Settings con navegación condicional
            HStack {
                // Botón izquierdo: Dashboard
                if selectedTab == .dashboard {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    NavigationLink(destination: ScreenDashboard().environmentObject(authController)) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.537, green: 0.616, blue: 0.733))
                    }
                }

                Spacer()

                // Botón derecho: Perfil
                if selectedTab == .profile {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    NavigationLink(destination: ScreenEditarPerfil()) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.537, green: 0.616, blue: 0.733))
                    }
                }
            }
            .padding(.horizontal, 55)

            // Botón central elevado (Home) con navegación condicional
            if selectedTab == .home {
                Button(action: { /* ya estás en Home, no navega */ }) {
                    ZStack {
                        Circle()
                            .fill(turquoise)
                            .frame(width: 70, height: 70)
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                        Image(systemName: "house.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -25)
            } else {
                NavigationLink(destination: ScreenHome().environmentObject(authController)) {
                    ZStack {
                        Circle()
                            .fill(turquoise)
                            .frame(width: 70, height: 70)
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                        Image(systemName: "house.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -25)
            }
        }
        .frame(height: barHeight)
    }
}

struct TabButton: View {
    let icon: String
    let tab: Tab
    @Binding var selectedTab: Tab

    var body: some View {
        Button(action: { selectedTab = tab }) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(selectedTab == tab ? .white : Color(red: 0.537, green: 0.616, blue: 0.733))
        }
    }
}

#Preview {
    ScreenHome()
}
