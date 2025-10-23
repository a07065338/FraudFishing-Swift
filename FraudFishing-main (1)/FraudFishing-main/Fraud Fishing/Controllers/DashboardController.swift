import Foundation
import SwiftUI

@MainActor
class DashboardController: ObservableObject {
    @Published var reports: [ReportResponse] = []
    @Published var categories: [CategoryDTO] = []
    @Published var selectedCategory: String = "Todas"
    @Published var selectedURL: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let httpReport = HTTPReport()
    private let categoriesController = CategoriesController()
    
    // Computed properties
    var filteredReports: [ReportResponse] {
        var filtered = reports
        
        // Filtrar por URL si está seleccionada
        if let selectedURL = selectedURL {
            filtered = filtered.filter { $0.url == selectedURL }
        }
        
        // Filtrar por categoría
        if selectedCategory != "Todas" {
            filtered = filtered.filter { $0.categoryName == selectedCategory }
        }
        
        return filtered.sorted { $0.voteCount > $1.voteCount }
    }
    
    var topReports: [ReportResponse] {
        return Array(filteredReports.prefix(3))
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        async let categoriesTask = loadCategories()
        async let reportsTask = loadPopularReports()
        
        await categoriesTask
        await reportsTask
        
        isLoading = false
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
    
    func selectURL(_ url: String?) {
        selectedURL = url
        // Resetear categoría a "Todas" cuando se selecciona una URL
        if url != nil {
            selectedCategory = "Todas"
        }
    }
    
    func clearFilters() {
        selectedCategory = "Todas"
        selectedURL = nil
    }
    
    func refreshData() async {
        await loadData()
    }
    
    // MARK: - Private Methods
    
    private func loadCategories() async {
        await categoriesController.fetchCategories()
        if let error = categoriesController.errorMessage {
            print("Error loading categories: \(error)")
            errorMessage = "Error al cargar categorías"
        } else {
            categories = categoriesController.categories
        }
    }
    
    private func loadPopularReports() async {
        do {
            let fetchedReports = try await httpReport.searchReports(
                status: nil,
                userId: nil,
                categoryId: nil,
                url: nil,
                sort: "popular",
                include: ["status", "category", "user", "tags"],
                page: 1,
                limit: 50
            )
            reports = fetchedReports
        } catch {
            print("Error loading reports: \(error)")
            errorMessage = "Error al cargar reportes"
        }
    }
}
