import SwiftUI

struct ReportDetailView: View {
    @Binding var report: ReportResponse

    @State private var comments: [CommentResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var commentTitle: String = ""
    @State private var commentContent: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                Color(red: 0.043, green: 0.067, blue: 0.173)
            ]), startPoint: UnitPoint(x:0.5, y:0.1), endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .background(Color(red: 0.0, green: 0.71, blue: 0.737))
                            .clipShape(Circle())
                    }
                    
                    Text("Detalle del Reporte")
                        .foregroundColor(.white)
                        .font(.poppinsSemiBold(size: 18))
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 25)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 20) {
                        // Tarjeta del reporte (mismo estilo que ReporteItemCard)
                        ReportDetailCard(report: report)
                            .padding(.horizontal, 20)
                        
                        // Sección de comentarios
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                Text("Comentarios")
                                    .font(.poppinsSemiBold(size: 18))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(comments.count)")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.3))
                                    )
                            }
                            .padding(.horizontal, 20)
                            
                            if isLoading {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .tint(Color(red: 0.0, green: 0.71, blue: 0.737))
                                    Text("Cargando comentarios...")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else if let errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 20)
                            } else if comments.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.3))
                                    Text("Sin comentarios aún")
                                        .font(.poppinsRegular(size: 16))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Sé el primero en comentar")
                                        .font(.poppinsRegular(size: 14))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(comments.reversed(), id: \.id) { comment in
                                        CommentBubble(comment: comment)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 180) // Espacio para el input de comentarios con título
                    }
                    .padding(.top, 10)
                }
            }
            
            // Barra de chat fija en la parte inferior
            ChatInputBar(
                titleText: $commentTitle,
                contentText: $commentContent,
                isLoading: isLoading,
                onSend: {
                    Task { await addComment() }
                }
            )
        }
        .navigationBarHidden(true)
        .task { await loadComments() }
    }

    private func loadComments() async {
        isLoading = true
        errorMessage = nil
        do {
            let list = try await HTTPComment().fetchComments(reportId: report.id)
            comments = list
        } catch {
            errorMessage = "No se pudieron cargar los comentarios."
        }
        isLoading = false
    }

    private func addComment() async {
        let title = commentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = commentContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty && !content.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let newComment = try await HTTPComment().createCommentWithTitle(
                reportId: report.id,
                title: title,
                content: content
            )
            comments.insert(newComment, at: 0)
            commentTitle = ""
            commentContent = ""
        } catch {
            // Manejo de errores más específico
            if let urlError = error as? URLError {
                switch urlError.code {
                case .userAuthenticationRequired:
                    errorMessage = "Debes iniciar sesión para comentar."
                case .badURL:
                    errorMessage = "Error de configuración. Intenta más tarde."
                case .badServerResponse:
                    errorMessage = "Error del servidor. Verifica tu conexión."
                default:
                    errorMessage = "Error de conexión. Verifica tu internet."
                }
            } else if let nsError = error as NSError? {
                if nsError.domain == "ServerError" {
                    errorMessage = nsError.localizedDescription
                } else {
                    errorMessage = "No se pudo enviar el comentario: \(nsError.localizedDescription)"
                }
            } else {
                errorMessage = "No se pudo enviar el comentario. Intenta nuevamente."
            }
            print("Error al enviar comentario: \(error)")
        }
        
        isLoading = false
    }
}
struct ReportDetailCard: View {
    let report: ReportResponse
    @State private var showImageOverlay = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con fecha y categoría
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
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                
                // Badge de estado
                estadoBadge(statusId: report.statusId)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Categoría
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 0.0, green: 0.8, blue: 0.7))
                        .frame(width: 6, height: 6)
                    Text(report.categoryName ?? "Desconocida")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 0.0, green: 0.8, blue: 0.7, opacity: 0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 0.0, green: 0.8, blue: 0.7, opacity: 0.3), lineWidth: 1)
                        )
                )
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Título del reporte
            HStack {
                Text(report.title)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // Imagen clickeable
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
                                        .font(.caption)
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
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .frame(height: 180)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Contenido
            VStack(alignment: .leading, spacing: 16) {
                // URL
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
                            .font(.callout.weight(.semibold))
                            .foregroundColor(.white)
                            .lineLimit(3)
                    }
                }
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
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Text(report.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.95))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Tags
                if let tags = report.tags, !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                                .font(.system(size: 11, weight: .semibold))
                            Text("Etiquetas")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tags, id: \.id) { tag in
                                    Text(tag.name)
                                        .font(.caption.weight(.medium))
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
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
        .shadow(color: Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.08), radius: 20, x: 0, y: 10)
        .overlay(
            // Overlay de imagen
            ImageOverlay(imageUrl: report.imageUrl, isPresented: $showImageOverlay)
        )
    }
    
    private func formatDate(_ isoString: String) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: isoString) {
            let out = DateFormatter()
            out.dateFormat = "dd/MM/yyyy HH:mm"
            return out.string(from: date)
        }
        return isoString
    }
    
    private func estadoBadge(statusId: Int) -> some View {
        let (text, color): (String, Color) = {
            switch statusId {
            case 2: return ("Verificado", Color.green)
            case 1: return ("En revisión", Color.orange)
            default: return ("Desconocido", Color.gray)
            }
        }()

        return HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.white)
            Text(text)
                .font(.caption2.weight(.bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color)
        .cornerRadius(12)
    }
}

// MARK: - Comment Bubble Component

struct CommentBubble: View {
    let comment: CommentResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                        .font(.system(size: 14))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Usuario \(comment.userId ?? 0)")
                        .font(.poppinsSemiBold(size: 14))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(formatCommentDate(comment.createdAt))
                            .font(.poppinsRegular(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
            }
            
            // Título del comentario
            if !comment.title.isEmpty {
                Text(comment.title)
                    .font(.poppinsSemiBold(size: 16))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            
            // Contenido del comentario
            Text(comment.content)
                .font(.poppinsRegular(size: 14))
                .foregroundColor(.white.opacity(0.95))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func formatCommentDate(_ isoString: String) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: isoString) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            formatter.locale = Locale(identifier: "es")
            return formatter.localizedString(for: date, relativeTo: Date())
        }
        return isoString
    }
}

// MARK: - Chat Input Bar Component

struct ChatInputBar: View {
    @Binding var titleText: String
    @Binding var contentText: String
    let isLoading: Bool
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.2))
            
            VStack(spacing: 12) {
                // Title field
                HStack(spacing: 8) {
                    Image(systemName: "textformat")
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.6))
                        .font(.system(size: 16))
                    
                    TextField("Título del comentario...", text: $titleText)
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
                
                HStack(spacing: 12) {
                    // Content field
                    HStack(spacing: 8) {
                        Image(systemName: "text.bubble")
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.6))
                            .font(.system(size: 16))
                        
                        TextField("Escribe el contenido...", text: $contentText, axis: .vertical)
                            .lineLimit(1...4)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                    
                    // Send button
                    Button(action: onSend) {
                        ZStack {
                            Circle()
                                .fill(
                                    titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                                    contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                                    isLoading
                                    ? Color.gray.opacity(0.5)
                                    : Color(red: 0.0, green: 0.71, blue: 0.737)
                                )
                                .frame(width: 44, height: 44)
                            
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.up")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                    }
                    .disabled(
                        titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                        contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                        isLoading
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.95),
                        Color(red: 0.043, green: 0.067, blue: 0.173)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}
// MARK: - Preview

struct ReportDetailView_PreviewContainer: View {
    @State private var mockReport = ReportResponse(
        id: 1,
        userId: 17,
        categoryId: 1,
        title: "Correo Sospechoso de Banco",
        description: "Recibí un correo sospechoso pidiéndome restablecer mi contraseña. El link me lleva a esta página que parece ser fraudulenta.",
        url: "https://paginafake.com/login-banco-falso-muy-largo",
        statusId: 2,
        imageUrl: nil,
        voteCount: 42,
        commentCount: 3,
        createdAt: "2025-10-17T14:30:00.000Z",
        updatedAt: "2025-10-17T14:30:00.000Z",
        tags: [
            TagResponse(id: 1, name: "banco"),
            TagResponse(id: 2, name: "urgente"),
            TagResponse(id: 3, name: "credenciales")
        ],
        categoryName: "Phishing"
    )
    
    var body: some View {
        ReportDetailView(report: $mockReport)
    }
}

#Preview {
    ReportDetailView_PreviewContainer()
}
