protocol RemoveFromCartUseCaseProtocol {
    func execute(bookID: String)
}

final class RemoveFromCartUseCase: RemoveFromCartUseCaseProtocol {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }

    func execute(bookID: String) {
        repository.remove(bookID: bookID)
    }
}
