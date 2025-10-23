import SwiftUI

struct ReportesPorURLView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var reports: [ReportResponse]
    let searchedURL: String

    @State private var displayedCount = 0
    @State private var isLoadingMore = false

    private let pageSize = 10

    private var visibleReports: [ReportResponse] {
        Array(reports.prefix(displayedCount))
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                Color(red: 0.043, green: 0.067, blue: 0.173)]),
                           startPoint: UnitPoint(x:0.5, y:0.1),
                           endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reportes para:")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text(searchedURL)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    LazyVStack(spacing: 12) {
                        ForEach(visibleReports.indices, id: \.self) { index in
                            NavigationLink(destination: ReportDetailView(report: $reports[index])) {
                                ReporteItemCard(report: $reports[index])
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 20)
                            .onAppear {
                                if index == visibleReports.count - 1 {
                                    loadMoreIfNeeded()
                                }
                            }
                        }

                        if isLoadingMore {
                            ProgressView("Cargando más...")
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            displayedCount = min(pageSize, reports.count)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.1)).frame(width: 36, height: 36)
                        Image(systemName: "chevron.left").foregroundColor(.white).font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
    }

    private func loadMoreIfNeeded() {
        guard !isLoadingMore else { return }
        guard displayedCount < reports.count else { return }
        isLoadingMore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            displayedCount = min(displayedCount + pageSize, reports.count)
            isLoadingMore = false
        }
    }
}
