import Foundation

@MainActor
final class BookDetailViewModel: ObservableObject {
    let book: Book
    @Published private(set) var isFavorite: Bool

    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let addToCartUseCase: AddToCartUseCaseProtocol

    init(
        book: Book,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        addToCartUseCase: AddToCartUseCaseProtocol
    ) {
        self.book = book
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.favoritesRepository = favoritesRepository
        self.addToCartUseCase = addToCartUseCase
        self.isFavorite = favoritesRepository.isFavorite(bookID: book.id)
    }

    func toggleFavorite() {
        toggleFavoriteUseCase.execute(book: book)
        isFavorite = favoritesRepository.isFavorite(bookID: book.id)
    }

    func addToCart() {
        addToCartUseCase.execute(book: book)
    }
}
