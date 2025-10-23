//
//  SrceenDashboard.swift
//  Fraud Fishing
//
//  Created by Victor Bosquez on 02/10/25.
//
//

import SwiftUI
import Foundation

// MARK: - URLItem para navegación
struct URLItem: Identifiable {
    let id = UUID()
    let url: String
}

// MARK: - Controller para reportes por URL
@MainActor
class URLReportsController: ObservableObject {
    @Published var reports: [ReportResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let httpReport = HTTPReport()
    
    var totalVotes: Int {
        reports.reduce(0) { $0 + $1.voteCount }
    }
    
    var mainCategory: String? {
        let categories = reports.compactMap { $0.categoryName }
        let categoryCount = Dictionary(grouping: categories, by: { $0 })
            .mapValues { $0.count }
        return categoryCount.max(by: { $0.value < $1.value })?.key
    }
    
    func loadReports(for url: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            reports = try await httpReport.searchReports(byURL: url)
        } catch {
            errorMessage = "Error al cargar reportes: \(error.localizedDescription)"
            print("Error loading reports for URL \(url): \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Vista de reportes filtrados por URL
struct URLReportsView: View {
    let url: String
    @Binding var isPresented: URLItem?
    @StateObject private var controller = URLReportsController()
    @Environment(\.dismiss) private var dismiss
    
    private var displayURL: String {
        if url.hasPrefix("http://") {
            return String(url.dropFirst(7))
        } else if url.hasPrefix("https://") {
            return String(url.dropFirst(8))
        }
        return url
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con gradiente
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)]),
                               startPoint: UnitPoint(x:0.5, y:0.1),
                               endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Button("Cerrar") {
                                isPresented = nil
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Text("Reportes para")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                Text(displayURL)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            // Placeholder para balance visual
                            Color.clear.frame(width: 50)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        // Contenido
                        if controller.isLoading {
                            Spacer()
                            VStack(spacing: 16) {
                                ProgressView()
                                    .tint(Color(red: 0.0, green: 0.8, blue: 0.7))
                                    .scaleEffect(1.2)
                                Text("Cargando reportes...")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                        } else if let errorMessage = controller.errorMessage {
                            Spacer()
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red.opacity(0.7))
                                Text("Error al cargar reportes")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        } else if controller.reports.isEmpty {
                            Spacer()
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.3))
                                Text("No hay reportes")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("No se encontraron reportes para esta URL")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        } else {
                            // Lista de reportes
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    // Estadísticas resumidas
                                    VStack(spacing: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Total de reportes")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.7))
                                                Text("\(controller.reports.count)")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("Total de votos")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.7))
                                                Text("\(controller.totalVotes)")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                                            }
                                        }
                                        
                                        if let mainCategory = controller.mainCategory {
                                            HStack {
                                                Text("Categoría principal:")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.7))
                                                Text(mainCategory)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(Color(red: 0.0, green: 0.8, blue: 0.7))
                                                    .cornerRadius(6)
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 20)
                                    
                                    // Lista de reportes
                                    ForEach(controller.reports.indices, id: \.self) { index in
                                        NavigationLink(destination: ReportDetailView(report: $controller.reports[index])) {
                                            CompactReportCard(report: $controller.reports[index])
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal, 20)
                                    }
                                }
                                .padding(.bottom, 20)
                            }
                        }
                    }
                    
                }
            }
            .onAppear {
                Task {
                    await controller.loadReports(for: url)
                }
            }
        }
    }
}

struct ScreenDashboard: View {
    @StateObject private var dashboardController = DashboardController()
    @State private var showNotificaciones: Bool = false
    @State private var selectedTab: Tab = .dashboard
    @State private var showReportsForURL: URLItem? = nil
    @State private var hasAnimatedScroll = false
    @EnvironmentObject var authController: AuthenticationController
    
    // Computed property for all categories
    private var allCategories: [String] {
        var categories = ["Todas"]
        categories.append(contentsOf: dashboardController.categories.map { $0.name })
        return categories
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Capa 1: Contenido principal con fondo
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)]),
                               startPoint: UnitPoint(x:0.5, y:0.1),
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    // Botón para limpiar filtros si hay una URL seleccionada
                    if dashboardController.selectedURL != nil {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dashboardController.clearFilters()
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Limpiar filtros")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(20)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                    
                    // Header con título y notificaciones
                    HStack {
                        Text("Reportes Destacados")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 15)

                    // Filtros de categorías con scroll horizontal
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(allCategories, id: \.self) { categoria in
                                    CategoryChip(
                                        title: categoria,
                                        isSelected: dashboardController.selectedCategory == categoria,
                                        action: {
                                            withAnimation(.spring(response: 0.3)) {
                                                dashboardController.selectCategory(categoria)
                                            }
                                        }
                                    )
                                    .id(categoria)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .onAppear {
                            if !hasAnimatedScroll && allCategories.count > 3 {
                                hasAnimatedScroll = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeInOut(duration: 2.0)) {
                                        proxy.scrollTo(allCategories.last, anchor: .trailing)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        withAnimation(.easeInOut(duration: 2.0)) {
                                            proxy.scrollTo(allCategories.first, anchor: .leading)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)

                    // Contenido principal con scroll vertical
                    ScrollView {
                        VStack(spacing: 16) {
                            if dashboardController.isLoading {
                                // Estado de carga
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .tint(Color(red: 0.0, green: 0.8, blue: 0.7))
                                        .scaleEffect(1.2)
                                    Text("Cargando reportes...")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.top, 60)
                            } else if let errorMessage = dashboardController.errorMessage {
                                // Estado de error
                                VStack(spacing: 16) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 50))
                                        .foregroundColor(.red.opacity(0.7))
                                    Text("Error al cargar")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text(errorMessage)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                    Button("Reintentar") {
                                        Task {
                                            await dashboardController.refreshData()
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 0.0, green: 0.8, blue: 0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .padding(.top, 60)
                            } else if dashboardController.filteredReports.isEmpty {
                                // Estado vacío
                                DashboardEmptyStateView(
                                    icon: "magnifyingglass",
                                    message: "No hay reportes",
                                    description: "No se encontraron reportes en esta categoría"
                                )
                                .padding(.top, 60)
                            } else {
                                // Top 3 sitios más reportados
                                HStack(spacing: 12) {
                                    let filteredReports = dashboardController.selectedCategory == "Todas" ? 
                                        dashboardController.reports.sorted { $0.voteCount > $1.voteCount } :
                                        dashboardController.reports
                                            .filter { $0.categoryName == dashboardController.selectedCategory }
                                            .sorted { $0.voteCount > $1.voteCount }
                                    let topReports = Array(filteredReports.prefix(3))
                                    
                                    ForEach(Array(topReports.enumerated()), id: \.element.id) { index, reporte in
                                        TopSiteCard(
                                            report: reporte,
                                            position: index + 1,
                                            onTap: {
                                                // Filtrar reportes por esta URL en la vista principal
                                                withAnimation(.spring(response: 0.3)) {
                                                    dashboardController.selectURL(reporte.url)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Cards compactos de reportes con scroll vertical
                                LazyVStack(spacing: 16) {
                                    let filteredReports = dashboardController.reports
                                        .filter { report in
                                            // Filtrar por URL si está seleccionada
                                            if let selectedURL = dashboardController.selectedURL {
                                                return report.url == selectedURL
                                            }
                                            return true
                                        }
                                        .filter { report in
                                            // Filtrar por categoría
                                            if dashboardController.selectedCategory != "Todas" {
                                                return report.categoryName == dashboardController.selectedCategory
                                            }
                                            return true
                                        }
                                        .sorted { $0.voteCount > $1.voteCount }
                                    
                                    ForEach(Array(filteredReports.enumerated()), id: \.element.id) { index, report in
                                        let reportIndex = dashboardController.reports.firstIndex { $0.id == report.id } ?? 0
                                        NavigationLink(destination: ReportDetailView(report: $dashboardController.reports[reportIndex])) {
                                            CompactReportCard(report: $dashboardController.reports[reportIndex])
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        await dashboardController.refreshData()
                    }
                }
                .padding(.bottom, 88) // Espacio para la tab bar
            }

            // Capa 2: CustomTabBar como vista aparte
            CustomTabBar(selectedTab: $selectedTab)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showNotificaciones) {
            ScreenNotifications().environmentObject(authController)
        }
        .sheet(item: $showReportsForURL) { urlItem in
            URLReportsView(url: urlItem.url, isPresented: $showReportsForURL)
        }
        .onAppear {
            Task {
                await dashboardController.loadData()
            }
        }
    }
}

// MARK: - Image Overlay View
struct ImageOverlayView: View {
    let imageURL: String
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Fondo semitransparente que permite ver el contenido de atrás
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissOverlay()
                }
            
            VStack(spacing: 20) {
                // Botón de cierre
                HStack {
                    Spacer()
                    Button(action: {
                        dismissOverlay()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // Imagen principal con fondo semitransparente
                if let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            VStack(spacing: 16) {
                                ProgressView()
                                    .tint(Color(red: 0.0, green: 0.8, blue: 0.7))
                                    .scaleEffect(1.5)
                                Text("Cargando imagen...")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .background(Color.black.opacity(0.9))
                            .cornerRadius(16)
                            
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.main.bounds.width - 40)
                                .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                        case .failure(let error):
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red.opacity(0.8))
                                Text("Error al cargar la imagen")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("No se pudo cargar la imagen desde el servidor")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                Button("Cerrar") {
                                    dismissOverlay()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .background(Color.black.opacity(0.9))
                            .cornerRadius(16)
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.orange.opacity(0.8))
                        Text("URL de imagen inválida")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Text("La URL proporcionada no es válida")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        
                        Button("Cerrar") {
                            dismissOverlay()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(16)
                }
                
                Spacer()
            }
            Spacer()
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func dismissOverlay() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}


// MARK: - Empty State View
struct DashboardEmptyStateView: View {
    let icon: String
    let message: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            Text(message)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Componente Category Chip

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.0, green: 0.2, blue: 0.4))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    isSelected ?
                    Color(red: 0.0, green: 0.8, blue: 0.7) :
                    Color.white
                )
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.08), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - TopSiteCard
struct TopSiteCard: View {
    let report: ReportResponse
    let position: Int
    let onTap: () -> Void
    
    var medalColor: Color {
        switch position {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0) // Oro
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75) // Plata
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronce
        default: return Color.gray
        }
    }
    
    var medalGradient: LinearGradient {
        switch position {
        case 1: return LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 0.9, green: 0.7, blue: 0.0)], startPoint: .top, endPoint: .bottom)
        case 2: return LinearGradient(colors: [Color(red: 0.75, green: 0.75, blue: 0.75), Color(red: 0.6, green: 0.6, blue: 0.6)], startPoint: .top, endPoint: .bottom)
        case 3: return LinearGradient(colors: [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.7, green: 0.4, blue: 0.1)], startPoint: .top, endPoint: .bottom)
        default: return LinearGradient(colors: [Color.gray, Color.gray.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    private var displayURL: String {
        let url = report.url
        if url.hasPrefix("http://") {
            return String(url.dropFirst(7))
        } else if url.hasPrefix("https://") {
            return String(url.dropFirst(8))
        }
        return url
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Medalla de posición
                ZStack {
                    Circle()
                        .fill(medalGradient)
                        .frame(width: 50, height: 50)
                        .shadow(color: medalColor.opacity(0.4), radius: 6, x: 0, y: 3)
                    
                    Text("\(position)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // URL
                Text(displayURL)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Votos
                VStack(spacing: 4) {
                    Text("\(report.voteCount)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("votos")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.6))
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(medalColor.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ScreenDashboard()
}
