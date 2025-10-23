import Foundation

// MARK: - Comment Response
struct CommentResponse: Codable, Identifiable {
    let id: Int
    let reportId: Int
    let userId: Int?
    let title: String
    let content: String
    let createdAt: String
    
    // Computed property para compatibilidad con el código existente
    var text: String {
        return content
    }
}

// MARK: - Create Comment Request
struct CreateCommentRequest: Codable {
    let reportId: Int
    let title: String
    let content: String
    
    // Inicializador de conveniencia para crear comentario con solo texto
    init(reportId: Int, text: String) {
        self.reportId = reportId
        self.title = "Comentario"
        self.content = text
    }
    
    // Inicializador completo
    init(reportId: Int, title: String, content: String) {
        self.reportId = reportId
        self.title = title
        self.content = content
    }
}