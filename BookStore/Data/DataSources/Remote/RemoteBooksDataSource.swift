import BookStoreNetworkingKit

/// Adapta la API pública del XCFramework (BooksAPIServiceProtocol) a una
/// abstracción propia de la capa Data, para no acoplar el resto de la app
/// directamente al framework.
protocol RemoteBooksDataSourceProtocol {
    func fetchBooks() async throws -> [GoogleBooksVolumeDTO]
}

final class RemoteBooksDataSource: RemoteBooksDataSourceProtocol {
    private let apiService: BooksAPIServiceProtocol
    private let query: String
    private let maxResults: Int

    init(
        apiService: BooksAPIServiceProtocol = GoogleBooksAPIService(),
        query: String = "subject:fiction",
        maxResults: Int = 20
    ) {
        self.apiService = apiService
        self.query = query
        self.maxResults = maxResults
    }

    func fetchBooks() async throws -> [GoogleBooksVolumeDTO] {
        let response = try await apiService.searchBooks(query: query, maxResults: maxResults)
        return response.items ?? []
    }
}
