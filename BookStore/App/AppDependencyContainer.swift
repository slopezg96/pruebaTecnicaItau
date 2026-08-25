import Foundation

/// Inyección de dependencias manual (protocolos + factory simple), sin
/// frameworks de DI externos. Construye una única vez los repositorios
/// compartidos y crea los ViewModels de cada pantalla bajo demanda.
final class AppDependencyContainer {
    private let booksRepository: BooksRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    init() {
        self.booksRepository = BooksRepositoryImpl(
            remoteDataSource: RemoteBooksDataSource(),
            localDataSource: MockBooksDataSource()
        )
        self.favoritesRepository = FavoritesRepositoryImpl()
    }

    @MainActor
    func makeCatalogViewModel() -> CatalogViewModel {
        CatalogViewModel(
            getBooksUseCase: GetBooksUseCase(repository: booksRepository),
            favoritesRepository: favoritesRepository
        )
    }
}
