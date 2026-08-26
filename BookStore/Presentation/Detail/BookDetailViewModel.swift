import Foundation

@MainActor
final class BookDetailViewModel: ObservableObject {
    let book: Book
    @Published private(set) var isFavorite: Bool
    @Published private(set) var cartQuantity: Int

    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let addToCartUseCase: AddToCartUseCaseProtocol
    private let cartRepository: CartRepositoryProtocol

    init(
        book: Book,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        addToCartUseCase: AddToCartUseCaseProtocol,
        cartRepository: CartRepositoryProtocol
    ) {
        self.book = book
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.favoritesRepository = favoritesRepository
        self.addToCartUseCase = addToCartUseCase
        self.cartRepository = cartRepository
        self.isFavorite = favoritesRepository.isFavorite(bookID: book.id)
        self.cartQuantity = Self.quantity(for: book.id, in: cartRepository)
    }

    func toggleFavorite() {
        toggleFavoriteUseCase.execute(book: book)
        isFavorite = favoritesRepository.isFavorite(bookID: book.id)
    }

    func addToCart() {
        addToCartUseCase.execute(book: book)
        cartQuantity = Self.quantity(for: book.id, in: cartRepository)
    }

    /// Se vuelve a consultar cada vez que la vista aparece: el carrito es una
    /// instancia compartida y puede haber cambiado desde otra pantalla
    /// (por ejemplo, quitando el libro desde el propio carrito).
    func refreshCartQuantity() {
        cartQuantity = Self.quantity(for: book.id, in: cartRepository)
    }

    private static func quantity(for bookID: String, in cartRepository: CartRepositoryProtocol) -> Int {
        cartRepository.getItems().first(where: { $0.book.id == bookID })?.quantity ?? 0
    }
}
