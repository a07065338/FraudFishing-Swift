import Foundation
import UIKit
import SwiftUI

class CreateReportController: ObservableObject {
    private let httpReport = HTTPReport()
    private let httpFile = HTTPFile()
    
    // MARK: - Published Properties
    @Published var isSending = false
    @Published var reportError: Error?
    @Published var isSuccess = false
    
    // MARK: - Image Upload Implementation
    private func uploadImageAndGetURL(imageData: Data?) async throws -> String? {
        guard let data = imageData else { return nil }
        
        guard let uiImage = UIImage(data: data) else {
            throw ReportError.imageProcessingFailed
        }
        
        guard let compressedData = uiImage.jpegData(compressionQuality: 0.7) else {
            throw ReportError.imageProcessingFailed
        }
        
        do {
            let httpFile = HTTPFile()
            let response = try await httpFile.uploadImage(imageData: compressedData)
            return response.path
        } catch {
            throw ReportError.imageUploadFailed(error)
        }
    }
    
    func sendReport(
        reportedURL: String,
        categoryId: Int,
        categoryName: String,
        tags: [String],
        description: String,
        selectedImageData: Data?
    ) async {
        DispatchQueue.main.async {
            self.isSending = true
            self.reportError = nil
            self.isSuccess = false
        }
        
        do {
            // 1. Validate required fields
            guard !reportedURL.isEmpty, !description.isEmpty else {
                throw ReportError.validationFailed(message: "Faltan campos obligatorios (URL, Descripción).")
            }
            
            // 2. Handle Image Upload
            let imageUrl = try await uploadImageAndGetURL(imageData: selectedImageData)
            
            // 3. Create DTO
            let reportRequest = CreateReportRequest(
                categoryId: categoryId,
                title: categoryName,
                description: description,
                url: reportedURL,
                tagNames: tags,
                imageUrl: imageUrl
            )
            
            // 4. Send Report
            let response = try await httpReport.createReport(reportData: reportRequest)
            
            // 5. Handle Success
            print("Reporte enviado con éxito. ID: \(response.id)")
            DispatchQueue.main.async {
                self.isSuccess = true
            }
            
        } catch {
            // 6. Handle Error
            print("Error al enviar reporte: \(error)")
            DispatchQueue.main.async {
                self.reportError = error
            }
        }
        
        DispatchQueue.main.async {
            self.isSending = false
        }
    }
    
    // MARK: - Error Handling
    enum ReportError: LocalizedError {
        case validationFailed(message: String)
        case imageProcessingFailed
        case imageUploadFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .validationFailed(let message):
                return message
            case .imageProcessingFailed:
                return "Error al procesar la imagen para subir."
            case .imageUploadFailed(let error):
                return "Error al subir la imagen: \(error.localizedDescription)"
            }
        }
    }
}
