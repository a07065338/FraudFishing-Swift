import SwiftUI


// MARK: - ScreenReportesPendientes
struct ScreenReportesPendientes: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = ReportesController()
    
    var body: some View {
        ZStack {
            // MARK: - Fondo
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white).padding(10)
                            .background(Color.white.opacity(0.1)).clipShape(Circle())
                    }
                    Spacer()
                    Text("Reportes Pendientes")
                        .font(.title2).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                // MARK: - Contenido
                if controller.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Spacer()
                } else if let errorMessage = controller.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red.opacity(0.7))
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Button("Reintentar") {
                            Task { await controller.fetchReportesPendientes() }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.cyan)
                        .cornerRadius(8)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            if controller.reportesPendientes.isEmpty {
                                EmptyStateView(
                                    icon: "clock.badge.questionmark",
                                    message: "No tienes reportes pendientes",
                                    description: "Tus reportes aparecerán aquí mientras son revisados"
                                )
                                .padding(.top, 100)
                            } else {
                                ForEach(controller.reportesPendientes) { reporte in
                                    ReporteCard(reporte: reporte)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await controller.fetchReportesPendientes()
        }
    }
}

// MARK: - ScreenReportesVerificados
struct ScreenReportesVerificados: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = ReportesController()
    
    var body: some View {
        ZStack {
            // MARK: - Fondo
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white).padding(10)
                            .background(Color.white.opacity(0.1)).clipShape(Circle())
                    }
                    Spacer()
                    Text("Reportes Verificados")
                        .font(.title2).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                // MARK: - Contenido
                if controller.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Spacer()
                } else if let errorMessage = controller.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red.opacity(0.7))
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Button("Reintentar") {
                            Task { await controller.fetchReportesVerificados() }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.cyan)
                        .cornerRadius(8)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            if controller.reportesVerificados.isEmpty {
                                EmptyStateView(
                                    icon: "checkmark.circle",
                                    message: "No tienes reportes verificados",
                                    description: "Tus reportes aceptados aparecerán aquí"
                                )
                                .padding(.top, 100)
                            } else {
                                ForEach(controller.reportesVerificados) { reporte in
                                    ReporteCard(reporte: reporte)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await controller.fetchReportesVerificados()
        }
    }
}

// MARK: - Modelo de Datos
// Estructura del reporte actualizada para incluir imageUrl
struct Reporte: Identifiable {
    let id: String
    let url: String
    let logo: String
    let descripcion: String
    let categoria: String
    let hashtags: String
    let estado: EstadoReporte
    let fechaCreacion: String
    var fechaVerificacion: String?
    let imageUrl: String? // Nueva propiedad para la imagen del reporte
}

enum EstadoReporte {
    case pendiente
    case verificado
}

// MARK: - Componente ReporteCard
struct ReporteCard: View {
    let reporte: Reporte
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con fecha y badge de estado
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "calendar")
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(reporte.fechaCreacion)
                    .font(.poppinsRegular(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                
                // Badge de estado del reporte
                HStack(spacing: 6) {
                    Image(systemName: reporte.estado == .pendiente ? "clock.fill" : "checkmark.circle.fill")
                        .font(.system(size: 11))
                    Text(reporte.estado == .pendiente ? "Pendiente" : "Verificado")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(reporte.estado == .pendiente ? Color.orange : Color.green)
                .cornerRadius(15)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Imagen con diseño mejorado
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15),
                                Color(red: 0.0, green: 0.6, blue: 0.7).opacity(0.08)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                // Patrón de puntos decorativo
                Canvas { context, size in
                    let dotSize: CGFloat = 2
                    let spacing: CGFloat = 20
                    for x in stride(from: 0, to: size.width, by: spacing) {
                        for y in stride(from: 0, to: size.height, by: spacing) {
                            let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                            context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.05)))
                        }
                    }
                }
                
                // Área de imagen mejorada con soporte para imagen del reporte
                if let imageUrl = reporte.imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(Color(red: 0.0, green: 0.71, blue: 0.737))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                        case .failure:
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.red.opacity(0.6))
                                    .font(.system(size: 30))
                                Text("Error al cargar imagen")
                                    .font(.poppinsRegular(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else if !reporte.logo.isEmpty, let url = URL(string: reporte.logo) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(Color(red: 0.0, green: 0.71, blue: 0.737))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                        case .failure:
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.red.opacity(0.6))
                                    .font(.system(size: 30))
                                Text("Error al cargar")
                                    .font(.poppinsRegular(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 70, height: 70)
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 30))
                        }
                        Text("Sin imagen")
                            .font(.poppinsRegular(size: 12))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .frame(height: 180)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Contenido principal
            VStack(alignment: .leading, spacing: 16) {
                // URL con diseño mejorado
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "link")
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("URL detectada")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        Text(reporte.url)
                            .font(.callout)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                
                // Descripción
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                            .font(.system(size: 12, weight: .semibold))
                        Text("Descripción")
                            .font(.poppinsRegular(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Text(reporte.descripcion)
                        .font(.poppinsRegular(size: 15))
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Categoría
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "diamond.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                            .font(.poppinsSemiBold(size: 12))
                        Text("Categoría")
                            .font(.poppinsRegular(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Text(reporte.categoria)
                        .font(.poppinsSemiBold(size: 12))
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                // Etiquetas como chips individuales
                if !reporte.hashtags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                                .font(.poppinsSemiBold(size: 12))
                            Text("Etiquetas")
                                .font(.poppinsRegular(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // Convertir hashtags en chips individuales
                        let tags = reporte.hashtags.components(separatedBy: " ").filter { !$0.isEmpty }
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 2), alignment: .leading, spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag.replacingOccurrences(of: "#", with: ""))
                                    .font(.poppinsSemiBold(size: 12))
                                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            ZStack {
                // Fondo principal con gradiente sutil
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.25),
                        Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.15)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Borde sutil
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
        .shadow(color: Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.08), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Vista de Estado Vacío
struct EmptyStateView: View {
    let icon: String
    let message: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.4))
            
            Text(message)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

#Preview("Reportes Pendientes") {
    NavigationView {
        ScreenReportesPendientes()
    }
}

#Preview("Reportes Verificados") {
    NavigationView {
        ScreenReportesVerificados()
    }
}
