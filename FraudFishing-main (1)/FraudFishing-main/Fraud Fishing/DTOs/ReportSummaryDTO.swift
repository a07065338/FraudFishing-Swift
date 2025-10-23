import Foundation

// ℹ️ DTO para los detalles de un solo reporte (como en tu imagen)
// Puedes usar tu 'ReportResponse' existente si ya la tienes definida
// struct ReportDetail: Codable { ... }

// 1. Estructura para el resumen que mostrará la tarjeta
struct ReportSummaryDTO: Codable {
    let url: String // El URL que fue buscado
    let totalReports: Int // Total de reportes encontrados
    let mainCategory: String // Categoría más frecuente (ej: Phishing)
    let mainTag: String? // Tag más frecuente
}

// 2. Estructura para la respuesta completa de la API
struct ReportSummaryResponse: Codable {
    let summary: ReportSummaryDTO // El resumen para la tarjeta
    let reports: [ReportResponse] // La lista de reportes detallados (como tu imagen)
}
