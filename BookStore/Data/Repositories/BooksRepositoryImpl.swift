/// Implementación de `BooksRepositoryProtocol`: intenta la fuente remota
/// (Google Books) primero y, si falla o no devuelve resultados, cae
/// automáticamente a la fuente local mock — así la app nunca se queda
/// bloqueada en un estado de error por inestabilidad de red durante la demo.
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
