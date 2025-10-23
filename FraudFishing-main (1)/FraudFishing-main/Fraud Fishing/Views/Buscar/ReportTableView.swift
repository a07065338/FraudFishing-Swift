import SwiftUI

struct ReportTableView: View {
    let reports: [ReportResponse]
    let urlFixed: String

    private let colWidths: [CGFloat] = [
        70, 90, 90, 160, 220, 180, 80, 200, 80, 110, 160, 160
    ]

    var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    headerCell("ID", width: colWidths[0])
                    headerCell("Usuario ID", width: colWidths[1])
                    headerCell("Categoría ID", width: colWidths[2])
                    headerCell("Título", width: colWidths[3])
                    headerCell("Descripción", width: colWidths[4])
                    headerCell("URL", width: colWidths[5])
                    headerCell("Estado", width: colWidths[6])
                    headerCell("Imagen URL", width: colWidths[7])
                    headerCell("Votos", width: colWidths[8])
                    headerCell("Comentarios", width: colWidths[9])
                    headerCell("Creado", width: colWidths[10])
                    headerCell("Actualizado", width: colWidths[11])
                }
                Divider().background(Color.white.opacity(0.2))

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(reports, id: \.id) { r in
                            HStack(spacing: 10) {
                                cell("\(r.id)", width: colWidths[0])
                                cell("\(r.userId)", width: colWidths[1])
                                cell("\(r.categoryId)", width: colWidths[2])
                                cell(r.title, width: colWidths[3])
                                cell(r.description, width: colWidths[4])
                                cell(urlFixed, width: colWidths[5])
                                cell("\(r.statusId)", width: colWidths[6])
                                cell(r.imageUrl ?? "N/A", width: colWidths[7])
                                cell("\(r.voteCount)", width: colWidths[8])
                                cell("\(r.commentCount)", width: colWidths[9])
                                cell(r.createdAt, width: colWidths[10])
                                cell(r.updatedAt, width: colWidths[11])
                            }
                            Divider().background(Color.white.opacity(0.15))
                        }
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }

    private func headerCell(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.caption.bold())
            .foregroundColor(.white.opacity(0.95))
            .frame(width: width, alignment: .leading)
    }

    private func cell(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.white.opacity(0.9))
            .lineLimit(2)
            .truncationMode(.tail)
            .frame(width: width, alignment: .leading)
    }
}