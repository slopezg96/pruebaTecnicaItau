protocol GetFavoritesUseCaseProtocol {
    func execute() -> [Book]
}

final class GetFavoritesUseCase: GetFavoritesUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> [Book] {
        repository.getFavorites()
    }
}
