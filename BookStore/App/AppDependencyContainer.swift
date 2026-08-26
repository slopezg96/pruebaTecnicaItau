import Foundation

/// Inyección de dependencias manual (protocolos + factory simple), sin
/// frameworks de DI externos. Construye una única vez los repositorios
/// compartidos y crea los ViewModels de cada pantalla bajo demanda.
final class AppDependencyContainer {
    private let booksRepository: BooksRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let cartRepository: CartRepositoryProtocol

    init() {
        self.booksRepository = BooksRepositoryImpl(
            remoteDataSource: RemoteBooksDataSource(),
            localDataSource: MockBooksDataSource()
        )
        self.favoritesRepository = FavoritesRepositoryImpl()
        self.cartRepository = InMemoryCartRepository()
    }

    @MainActor
    func makeCatalogViewModel() -> CatalogViewModel {
        CatalogViewModel(
            getBooksUseCase: GetBooksUseCase(repository: booksRepository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favoritesRepository),
            favoritesRepository: favoritesRepository
        )
    }

    @MainActor
    func makeDetailViewModel(book: Book) -> BookDetailViewModel {
        BookDetailViewModel(
            book: book,
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favoritesRepository),
            favoritesRepository: favoritesRepository,
            addToCartUseCase: AddToCartUseCase(repository: cartRepository),
            cartRepository: cartRepository
        )
    }

    /// Instancia compartida (no una nueva por pantalla): así el carrito
    /// refleja lo agregado desde el detalle sin depender de persistencia.
    @MainActor
    private(set) lazy var cartViewModel: CartViewModel = CartViewModel(
        cartRepository: cartRepository,
        removeFromCartUseCase: RemoveFromCartUseCase(repository: cartRepository),
        cartTotalUseCase: CartTotalUseCase()
    )
}
