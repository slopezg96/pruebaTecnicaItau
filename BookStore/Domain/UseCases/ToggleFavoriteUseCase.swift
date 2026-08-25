protocol ToggleFavoriteUseCaseProtocol {
    func execute(book: Book)
}

final class ToggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(book: Book) {
        repository.toggleFavorite(book)
    }
}
