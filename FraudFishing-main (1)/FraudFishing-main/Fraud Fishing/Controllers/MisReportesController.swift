
import Foundation

@MainActor
class ReportesController: ObservableObject {
    @Published var reportesPendientes: [Reporte] = []
    @Published var reportesVerificados: [Reporte] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let httpReport = HTTPReport()
    
    func fetchReportesPendientes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let responses = try await httpReport.getMyReports(status: 2)
            // Procesar reportes en paralelo usando TaskGroup
            reportesPendientes = await convertReportsInParallel(responses, estado: .pendiente)
        } catch {
            errorMessage = "Error al cargar reportes: \(error.localizedDescription)"
            print("Error fetching reportes pendientes: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchReportesVerificados() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let responses = try await httpReport.getMyReports(status: 3)
            // Procesar reportes en paralelo usando TaskGroup
            reportesVerificados = await convertReportsInParallel(responses, estado: .verificado)
        } catch {
            errorMessage = "Error al cargar reportes: \(error.localizedDescription)"
            print("Error fetching reportes verificados: \(error)")
        }
        
        isLoading = false
    }
    
    // NUEVA FUNCIÓN: Procesar múltiples reportes en paralelo
    private func convertReportsInParallel(_ responses: [ReportResponse], estado: EstadoReporte) async -> [Reporte] {
        await withTaskGroup(of: (Int, Reporte).self) { group in
            // Crear una tarea por cada reporte
            for (index, response) in responses.enumerated() {
                group.addTask {
                    let reporte = await self.convertToReporteWithTags(response, estado: estado)
                    return (index, reporte)
                }
            }
            
            // Recolectar resultados manteniendo el orden original
            var reportes: [(Int, Reporte)] = []
            for await result in group {
                reportes.append(result)
            }
            
            // Ordenar por índice original y devolver solo los reportes
            return reportes.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }
    
    // Convertir ReportResponse a Reporte con tags y categoría del servidor
    // OPTIMIZADO: Ahora hace las dos llamadas en paralelo
    private func convertToReporteWithTags(_ response: ReportResponse, estado: EstadoReporte) async -> Reporte {
        // Formatear fechas
        let fechaCreacion = formatearFecha(response.createdAt)
        let fechaVerificacion = estado == .verificado ? formatearFecha(response.updatedAt) : nil
        
        // Ejecutar ambas llamadas en paralelo
        async let tagsResult = fetchTags(for: response.id)
        async let categoryResult = fetchCategory(for: response.id)
        
        let hashtags = await tagsResult
        let categoryName = await categoryResult
        
        return Reporte(
            id: String(response.id),
            url: response.url,
            logo: response.imageUrl ?? "",
            descripcion: response.description,
            categoria: categoryName,
            hashtags: hashtags,
            estado: estado,
            fechaCreacion: fechaCreacion,
            fechaVerificacion: fechaVerificacion,
            imageUrl: response.imageUrl ?? ""
        )
    }
    
    // NUEVO: Helper para obtener tags con manejo de errores
    private func fetchTags(for reportId: Int) async -> String {
        do {
            let tags = try await httpReport.getReportTags(reportId: reportId)
            return tags.map { "#\($0.name)" }.joined(separator: " ")
        } catch {
            print("Error fetching tags for report \(reportId): \(error)")
            return ""
        }
    }
    
    // NUEVO: Helper para obtener categoría con manejo de errores
    private func fetchCategory(for reportId: Int) async -> String {
        do {
            let categoryResponse = try await httpReport.getReportCategory(reportId: reportId)
            return categoryResponse.categoryName
        } catch {
            print("Error fetching category for report \(reportId): \(error)")
            return "Desconocido"
        }
    }
    
    // Helper para formatear fechas
    private func formatearFecha(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: isoString) else {
            return isoString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM yyyy"
        displayFormatter.locale = Locale(identifier: "es_ES")
        
        return displayFormatter.string(from: date)
    }
}
