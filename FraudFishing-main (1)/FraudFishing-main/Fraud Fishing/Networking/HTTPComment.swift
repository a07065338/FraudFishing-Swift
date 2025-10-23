import Foundation

final class HTTPComment {
    private let executor = RequestExecutor()

    func fetchComments(reportId: Int) async throws -> [CommentResponse] {
        guard let url = URL(string: "http://localhost:3000/comments/report/\(reportId)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _) = try await executor.send(request, requiresAuth: false)
        return try JSONDecoder().decode([CommentResponse].self, from: data)
    }

    func createComment(reportId: Int, text: String) async throws -> CommentResponse {
        guard let url = URL(string: "http://localhost:3000/comments") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(CreateCommentRequest(reportId: reportId, text: text))
        let (data, _) = try await executor.send(request, requiresAuth: true)
        return try JSONDecoder().decode(CommentResponse.self, from: data)
    }
    
    func createCommentWithTitle(reportId: Int, title: String, content: String) async throws -> CommentResponse {
        guard let url = URL(string: "http://localhost:3000/comments") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(CreateCommentRequest(reportId: reportId, title: title, content: content))
        
        do {
            let (data, response) = try await executor.send(request, requiresAuth: true)
            
            // Verificar el código de estado HTTP
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    // Intentar decodificar el error del servidor
                    if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                        throw NSError(domain: "ServerError", code: serverError.statusCode, userInfo: [NSLocalizedDescriptionKey: serverError.message])
                    } else {
                        throw URLError(.badServerResponse, userInfo: [
                            NSLocalizedDescriptionKey: "Error del servidor. Código: \(httpResponse.statusCode)"
                        ])
                    }
                }
            }
            
            return try JSONDecoder().decode(CommentResponse.self, from: data)
        } catch {
            print("Error en createCommentWithTitle: \(error)")
            throw error
        }
    }
}