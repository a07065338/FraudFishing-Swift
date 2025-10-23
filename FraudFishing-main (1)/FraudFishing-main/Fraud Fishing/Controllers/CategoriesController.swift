import Foundation

@MainActor
class CategoriesController: ObservableObject {
    @Published var categories: [CategoryDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let httpReport = HTTPReport()
    
    // Caché de categorías para evitar llamadas repetidas
    private var hasLoadedCategories = false
    
    func fetchCategories(forceRefresh: Bool = false) async {
        // Si ya se cargaron y no es refresh forzado, no hacer nada
        if hasLoadedCategories && !forceRefresh {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            categories = try await httpReport.getCategories()
            hasLoadedCategories = true
        } catch {
            errorMessage = "Error al cargar categorías: \(error.localizedDescription)"
            print("Error fetching categories: \(error)")
        }
        
        isLoading = false
    }
    
    // Helper para obtener el ID de una categoría por nombre
    func getCategoryId(byName name: String) -> Int? {
        return categories.first(where: { $0.name == name })?.id
    }
    
    // Helper para obtener el nombre de una categoría por ID
    func getCategoryName(byId id: Int) -> String? {
        return categories.first(where: { $0.id == id })?.name
    }
    
    // Resetear el caché
    func reset() {
        categories = []
        hasLoadedCategories = false
        errorMessage = nil
    }
}
