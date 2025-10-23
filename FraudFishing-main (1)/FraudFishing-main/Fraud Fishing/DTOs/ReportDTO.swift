import Foundation

struct CreateReportRequest: Codable {
    let categoryId: Int
    let title: String
    let description: String
    let url: String
    let tagNames: [String]
    let imageUrl: String?
}

struct TagResponse: Codable {
    let id: Int
    let name: String
}

// MARK: - VoteResponse
struct VoteResponse: Codable {
    let voteCount: Int
    let hasVoted: Bool
}

struct ReportResponse: Codable {
    let id: Int
    let userId: Int
    let categoryId: Int
    let title: String
    let description: String
    let url: String
    let statusId: Int
    let imageUrl: String?
    var voteCount: Int
    let commentCount: Int
    let createdAt: String
    let updatedAt: String
    let tags: [TagResponse]?
    let categoryName: String?
    var hasVoted: Bool?
}

// AÑADIR ESTO a ReportDTO.swift (o un archivo similar)
struct ServerErrorResponse: Decodable {
    let message: String
    let error: String?
    let statusCode: Int
}

// MARK: - Tags Array Response
// Si el endpoint devuelve un array directamente
typealias TagsResponse = [TagResponse]

// Categories
struct CategoryDTO: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String
}

typealias CategoriesResponse = [CategoryDTO]

struct ReportCategoryResponse: Codable {
    let categoryName: String
}
