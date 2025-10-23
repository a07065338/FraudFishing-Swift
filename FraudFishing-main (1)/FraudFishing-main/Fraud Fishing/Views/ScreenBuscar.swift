//
//  ScreenBuscar.swift
//  Fraud Fishing
//
//  Created by Javier Canella Ramos on 17/10/25.
//

import SwiftUI

struct ScreenBuscar: View {
    let searchedURL: String
    @State private var selectedTab: Tab = .dashboard
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authController: AuthenticationController

    // Estado de carga y datos
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var reports: [ReportResponse] = []
    @State private var summary: ReportSummaryDTO?
    @State private var categories: [String] = []
    @State private var tags: [String] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            // Fondo
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                Color(red: 0.043, green: 0.067, blue: 0.173)]),
                           startPoint: UnitPoint(x:0.5, y:0.1),
                           endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header con título y notificación
                ZStack {
                    VStack{
                        HStack {
                            // Botón de back
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(10)
                                    .background(Color(red: 0.0, green: 0.71, blue: 0.737))
                                    .clipShape(Circle())
                            }.padding(.top, 25)
                            
                            
                            Spacer()
                            
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
                            .padding(.top, 25)
                        }
                        
                        HStack {
                            Text("Resultados de búsqueda")
                                .font(.poppinsBold(size: 22))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 25)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Contenido principal con ScrollView
                ScrollView {
                    VStack(spacing: 24) {
                        if isLoading {
                            LoadingView()
                                .padding(.top, 60)
                        } else if let errorMessage {
                            ErrorView(message: errorMessage)
                                .padding(.top, 60)
                        } else if let summary {
                            NavigationLink(
                                destination: ReportesPorURLView(
                                    reports: $reports,
                                    searchedURL: summary.url
                                )
                            ) {
                                ResumenBusquedaCard(
                                    total: summary.totalReports,
                                    url: summary.url,
                                    tags: Array(tags.prefix(5)),
                                    categories: Array(categories.prefix(5))
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        } else {
                            EmptyResultsView(url: searchedURL)
                                .padding(.top, 60)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            
            // Tab bar pegada al fondo
            VStack {
                Spacer()
                BuscarTabBar(selectedTab: $selectedTab)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarHidden(true)
        .task { await fetchData() }
    }

    private func fetchData() async {
        isLoading = true
        errorMessage = nil
        do {
            let http = HTTPReport()
            let fetched = try await http.searchReports(byURL: searchedURL)
            await MainActor.run {
                // Mostrar solo reportes aprobados (statusId == 2)
                let approved = fetched.filter { $0.statusId == 2 }
                reports = approved
                summary = buildSummary(from: approved)
                let (cats, tgs) = aggregateCategoriesAndTags(from: approved)
                categories = cats
                tags = tgs
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error al buscar: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    private func buildSummary(from reports: [ReportResponse]) -> ReportSummaryDTO {
        let url = searchedURL
        let total = reports.count
        let cats = reports.compactMap { $0.categoryName ?? idToCategoryName($0.categoryId) }
        let mainCategory = cats.mostFrequent() ?? "N/A"
        let allTags = reports.flatMap { ($0.tags ?? []).map { $0.name } }
        let mainTag = allTags.mostFrequent()
        return ReportSummaryDTO(url: url, totalReports: total, mainCategory: mainCategory, mainTag: mainTag)
    }

    private func aggregateCategoriesAndTags(from reports: [ReportResponse]) -> ([String], [String]) {
        let cats = reports.compactMap { $0.categoryName ?? idToCategoryName($0.categoryId) }
        let tagNames = Set(reports.flatMap { ($0.tags ?? []).map { $0.name } })
        let topCats = Array(cats.frequencySorted().prefix(3))
        return (topCats, Array(tagNames))
    }

    private func idToCategoryName(_ id: Int) -> String {
        switch id {
        case 1: return "Phishing"
        case 2: return "Malware"
        case 3: return "Scam"
        case 4: return "Noticias Falsas"
        case 5: return "Otro"
        default: return "Desconocida"
        }
    }
}

// MARK: - Loading View Component

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Círculos animados de fondo
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            Color(red: 0.0, green: 0.71, blue: 0.737).opacity(0.2),
                            lineWidth: 2
                        )
                        .frame(width: 80 + CGFloat(index * 20), height: 80 + CGFloat(index * 20))
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
                
                // Ícono de búsqueda
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.0, green: 0.71, blue: 0.737).opacity(0.3),
                                    Color(red: 0.0, green: 0.71, blue: 0.737).opacity(0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.poppinsSemiBold(size: 32))
                        .foregroundColor(Color(red: 0.0, green: 0.71, blue: 0.737))
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 2)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
            }
            .frame(height: 160)
            
            VStack(spacing: 8) {
                Text("Buscando reportes...")
                    .font(.poppinsBold(size: 25))
                    .foregroundColor(.white)
                
                Text("Analizando la base de datos")
                    .font(.poppinsRegular(size: 16))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Barra de progreso animada
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.71, blue: 0.737),
                                Color(red: 0.0, green: 0.8, blue: 0.7)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: isAnimating ? 250 : 0, height: 6)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .frame(width: 250)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Error View Component

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.poppinsMedium(size: 32))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("Error en la búsqueda")
                    .font(.poppinsMedium(size: 32))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.poppinsRegular(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.red.opacity(0.2), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Empty Results View Component

struct EmptyResultsView: View {
    let url: String
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            VStack(spacing: 12) {
                Text("Sin resultados")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 6) {
                    Text("No se encontraron reportes para")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(url)
                        .font(.subheadline.bold())
                        .foregroundColor(Color(red: 0.0, green: 0.71, blue: 0.737))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.0, green: 0.71, blue: 0.737).opacity(0.15))
                        )
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                
                Text("Intenta buscar otra URL o crea un nuevo reporte")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
    }
}

#Preview {
    ScreenBuscar(searchedURL: "https://ejemplo.com")
}
