/// Implementación de `BooksRepositoryProtocol`: intenta la fuente remota
/// (Google Books) primero y, si falla o no devuelve resultados, cae
/// automáticamente a la fuente local mock, evitando que un fallo o una
/// inestabilidad de red bloqueen el catálogo en un estado de error.
final class BooksRepositoryImpl: BooksRepositoryProtocol {
    private let remoteDataSource: RemoteBooksDataSourceProtocol
    private let localDataSource: LocalBooksDataSourceProtocol

    init(
        remoteDataSource: RemoteBooksDataSourceProtocol,
        localDataSource: LocalBooksDataSourceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchCatalog() async throws -> [Book] {
        do {
            let dtos = try await remoteDataSource.fetchBooks()
            guard !dtos.isEmpty else {
                return try await localDataSource.fetchBooks()
            }
            return dtos.map(BookMapper.map)
        } catch {
            return try await localDataSource.fetchBooks()
        }
    }
}
