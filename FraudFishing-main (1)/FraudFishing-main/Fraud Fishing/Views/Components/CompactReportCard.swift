import SwiftUI

struct CompactReportCard: View {
    @Binding var report: ReportResponse
    @State private var showImageOverlay = false
    @State private var isVoting = false
    @State private var voteError: String? = nil
    
    // Controller para manejar la lógica de votación
    private let controller = ReportController()
    
    // Computed property para determinar si el usuario ha votado
    private var hasVoted: Bool {
        report.hasVoted ?? false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header compacto con título y votos
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
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
                
                Spacer()
                
                // Botón de votos
                Button {
                    Task { await toggleVote() }
                } label: {
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(report.voteCount)")
                                .font(.poppinsBold(size: 16))
                                .foregroundColor(.white)
                        }
                        ZStack {
                            Circle()
                                .fill(hasVoted ? Color(red: 0.0, green: 0.8, blue: 0.7) : Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: hasVoted ? "arrowshape.up.fill" : "arrowshape.up")
                                .foregroundColor(hasVoted ? .white : Color(red: 0.0, green: 0.8, blue: 0.7))
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: 60)
                    .padding(.vertical, 14)
                    .opacity(isVoting ? 0.5 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isVoting)
                
                // Mostrar error de voto si existe
                if let voteError = voteError {
                    Text(voteError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Imagen compacta
            Button(action: {
                if report.imageUrl != nil {
                    showImageOverlay = true
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
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
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
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
                                    .frame(height: 120)
                                    .clipped()
                                    .overlay(
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(6)
                                                    .background(Color.black.opacity(0.5))
                                                    .clipShape(Circle())
                                                    .padding(8)
                                            }
                                        }
                                    )
                            case .failure:
                                VStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.red.opacity(0.6))
                                        .font(.system(size: 24))
                                    Text("Error al cargar")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "photo")
                                    .foregroundColor(.white.opacity(0.4))
                                    .font(.system(size: 20))
                            }
                            Text("Sin imagen")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
            }
            .cornerRadius(12)
            .buttonStyle(PlainButtonStyle())
            .frame(height: 120)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            // Descripción compacta
            VStack(alignment: .leading, spacing: 8) {
                Text(report.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Tags compactos
                if let tags = report.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(tags.prefix(2)), id: \.id) { tag in
                                Text(tag.name)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                                    .padding(.horizontal, 8)
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
                            if tags.count > 2 {
                                Text("+\(tags.count - 2)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.25),
                        Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.15)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .shadow(color: Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.06), radius: 16, x: 0, y: 8)
        .overlay(
            // Overlay de imagen semitransparente
            Group {
                if showImageOverlay, let imageURL = report.imageUrl {
                    ImageOverlayView(imageURL: imageURL, isPresented: $showImageOverlay)
                }
            }
        )
    }
    
    // MARK: - Helper Methods
    
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

// Preview
struct CompactReportCard_Preview: View {
    @State private var mockReport = ReportResponse(
        id: 1,
        userId: 17,
        categoryId: 1,
        title: "Sitio Fraudulento Detectado",
        description: "Este sitio web está intentando robar información personal mediante técnicas de phishing.",
        url: "https://sitiofalso.com",
        statusId: 2,
        imageUrl: "https://images.unsplash.com/photo-1614064641938-3bbee52942c7?w=400",
        voteCount: 42,
        commentCount: 8,
        createdAt: "2025-10-17T14:30:00.000Z",
        updatedAt: "2025-10-17T14:30:00.000Z",
        tags: [
            TagResponse(id: 1, name: "phishing"),
            TagResponse(id: 2, name: "fraude")
        ],
        categoryName: "Phishing",
        hasVoted: false
    )
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                Color(red: 0.043, green: 0.067, blue: 0.173)]),
                           startPoint: UnitPoint(x:0.5, y:0.1),
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            CompactReportCard(report: $mockReport)
                .padding()
        }
    }
}

#Preview {
    CompactReportCard_Preview()
}
