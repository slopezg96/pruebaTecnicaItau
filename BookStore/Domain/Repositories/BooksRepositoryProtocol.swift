/// Abstracción de Domain: la capa de Data la implementa (API real con fallback
/// a mock, o cualquier otra fuente futura) sin que Domain ni Presentation
/// conozcan el detalle de esa implementación.
protocol BooksRepositoryProtocol {
    func fetchCatalog() async throws -> [Book]
}
