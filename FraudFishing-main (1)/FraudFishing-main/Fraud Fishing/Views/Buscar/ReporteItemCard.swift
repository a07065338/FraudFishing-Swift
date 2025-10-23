import SwiftUI

struct ReporteItemCard: View {
    @Binding var report: ReportResponse
    @State private var isVoting = false
    @State private var voteError: String? = nil
    @State private var showImageOverlay = false
    @State private var navigateToDetail = false
    
    // Controller para manejar la lógica de votación
    private let controller = ReportController()
    
    // Computed property para determinar si el usuario ha votado
    private var hasVoted: Bool {
        report.hasVoted ?? false
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header con fecha
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "calendar")
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(formatDate(report.createdAt))
                    .font(.poppinsRegular(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                
                // Badge de categoría en el header
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(red: 0.0, green: 0.8, blue: 0.7))
                        .frame(width: 6, height: 6)
                    Text(report.categoryName ?? "Desconocida")
                        .font(.poppinsSemiBold(size: 12))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 0.0, green: 0.8, blue: 0.7, opacity: 0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 0.0, green: 0.8, blue: 0.7, opacity: 0.3), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Título del reporte
            HStack {
                Text(report.title)
                    .font(.poppinsBold(size: 18))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // Imagen con diseño mejorado - Ahora clickeable
            Button(action: {
                if report.imageUrl != nil {
                    showImageOverlay = true
                }
            }) {
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
                    
                    if let imageUrl = report.imageUrl, let url = URL(string: imageUrl) {
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
                                    .overlay(
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.black.opacity(0.5))
                                                    .clipShape(Circle())
                                                    .padding(12)
                                            }
                                        }
                                    )
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
            }
            .cornerRadius(12)
            .buttonStyle(PlainButtonStyle())
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
                        Text(report.url)
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
                        Image(systemName: "text.quote")
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                            .font(.system(size: 12, weight: .semibold))
                        Text("Descripción")
                            .font(.poppinsRegular(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Text(report.description)
                        .font(.poppinsRegular(size: 15))
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Tags con diseño mejorado
                if let tags = report.tags, !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                                .font(.poppinsSemiBold(size: 12))
                            Text("Etiquetas")
                                .font(.poppinsRegular(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tags, id: \.id) { tag in
                                    Text(tag.name)
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
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Footer con estadísticas
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 20)
            
            HStack(spacing: 0) {
                // Botón de votos
                Button {
                    Task { await toggleVote() }
                } label: {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(hasVoted ? Color(red: 0.0, green: 0.8, blue: 0.7) : Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: hasVoted ? "arrowshape.up.fill" : "arrowshape.up")
                                .foregroundColor(hasVoted ? .white : Color(red: 0.0, green: 0.8, blue: 0.7))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(report.voteCount)")
                                .font(.poppinsBold(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .opacity(isVoting ? 0.5 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isVoting)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .frame(height: 40)
                
                // Botón de Comentarios - NavigationLink
                NavigationLink(destination: ReportDetailView(report: $report), isActive: $navigateToDetail) {
                    Button(action: {
                        navigateToDetail = true
                    }) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "bubble.right.fill")
                                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(report.commentCount)")
                                    .font(.poppinsBold(size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)

            if let voteError = voteError {
                Text(voteError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
            }
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
        .overlay(
            // Image Overlay
            ImageOverlay(imageUrl: report.imageUrl, isPresented: $showImageOverlay)
        )
    }

    // MARK: - Helper Methods
    
    private func formatDate(_ isoString: String) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: isoString) {
            let out = DateFormatter()
            out.dateFormat = "dd/MM/yyyy"
            return out.string(from: date)
        }
        return isoString
    }

    private func toggleVote() async {
        guard !isVoting else { return }
        isVoting = true
        voteError = nil
        
        do {
            // Llamar al controller
            let result = try await controller.toggleVote(reportId: report.id)
            
            await MainActor.run {
                // Actualizar el reporte con los valores del servidor
                report.voteCount = result.voteCount
                report.hasVoted = result.hasVoted
                isVoting = false
                
                // Feedback háptico
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        } catch let error as NSError {
            await MainActor.run {
                // Manejar diferentes tipos de errores
                if error.domain == "ServerError" {
                    voteError = error.localizedDescription
                } else if error.code == NSURLErrorUserAuthenticationRequired {
                    voteError = "Debes iniciar sesión para votar"
                } else if error.code == -1011 {
                    voteError = "Error de conexión con el servidor"
                } else {
                    voteError = "Error al procesar el voto"
                }
                isVoting = false
                
                print("Error al votar: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Image Overlay Component

struct ImageOverlay: View {
    let imageUrl: String?
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        if isPresented, let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            ZStack {
                // Fondo oscurecido
                Color.black.opacity(0.9)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            scale = 0.5
                            opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isPresented = false
                        }
                    }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                scale = 0.5
                                opacity = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .padding(20)
                        }
                    }
                    
                    Spacer()
                    
                    // Imagen ampliada
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                        case .failure:
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                                Text("Error al cargar la imagen")
                                    .foregroundColor(.white)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    Spacer().frame(height: 200)
                }
                .scaleEffect(scale)
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

// MARK: - Preview Container
struct ReporteItemCard_PreviewContainer: View {
    @State private var mockReport = ReportResponse(
        id: 1,
        userId: 17,
        categoryId: 1,
        title: "Correo Sospechoso de Banco",
        description: "Recibí un correo sospechoso pidiéndome restablecer mi contraseña. El link me lleva a esta página.",
        url: "https://paginafake.com",
        statusId: 2,
        imageUrl: "https://images.unsplash.com/photo-1614064641938-3bbee52942c7?w=800",
        voteCount: 42,
        commentCount: 8,
        createdAt: "2025-10-17T14:30:00.000Z",
        updatedAt: "2025-10-17T14:30:00.000Z",
        tags: [
            TagResponse(id: 1, name: "banco"),
            TagResponse(id: 2, name: "urgente"),
            TagResponse(id: 3, name: "credenciales")
        ],
        categoryName: "Phishing",
        hasVoted: false
    )

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)]),
                               startPoint: UnitPoint(x:0.5, y:0.1),
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                ReporteItemCard(report: $mockReport)
                    .padding()
            }
        }
    }
}

#Preview {
    ReporteItemCard_PreviewContainer()
}
