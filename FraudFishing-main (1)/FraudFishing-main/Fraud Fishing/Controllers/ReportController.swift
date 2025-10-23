import Foundation

final class ReportController {
    private let httpReport = HTTPReport()
    
    // MARK: - Toggle Vote
    /// Alterna el voto del usuario en un reporte
    /// - Parameter reportId: ID del reporte que se va a votar
    /// - Returns: Tupla con el nuevo estado (voteCount, hasVoted)
    func toggleVote(reportId: Int) async throws -> (voteCount: Int, hasVoted: Bool) {
        let response = try await httpReport.voteReport(reportId: reportId)
        return (voteCount: response.voteCount, hasVoted: response.hasVoted)
    }
    
    // MARK: - Fetch Reports
    func searchReports(byURL urlString: String) async throws -> [ReportResponse] {
        return try await httpReport.searchReports(byURL: urlString)
    }
    
    // MARK: - Create Report
    func createReport(reportData: CreateReportRequest) async throws -> ReportResponse {
        return try await httpReport.createReport(reportData: reportData)
    }
}
