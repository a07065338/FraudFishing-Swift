import Foundation

// DTO para la respuesta de subida de archivos
struct FileUploadResponse: Codable {
    let filename: String
    let path: String
    let mimetype: String
    let size: Int
}

final class HTTPFile {
    private let executor = RequestExecutor()
    
    /// Sube una imagen al servidor
    /// - Parameter imageData: Los datos de la imagen a subir
    /// - Returns: La respuesta con la información del archivo subido
    func uploadImage(imageData: Data) async throws -> FileUploadResponse {
        guard let url = URL(string: "http://localhost:3000/files/upload") else {
            throw URLError(.badURL)
        }
        
        // Crear boundary para multipart/form-data
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Crear el cuerpo multipart
        var body = Data()
        
        // Agregar el archivo
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Usar el executor que maneja la autenticación
        let (data, _) = try await executor.send(request, requiresAuth: true)
        
        return try JSONDecoder().decode(FileUploadResponse.self, from: data)
    }
}