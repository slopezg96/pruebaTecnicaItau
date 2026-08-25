protocol AddToCartUseCaseProtocol {
    func execute(book: Book)
}

final class AddToCartUseCase: AddToCartUseCaseProtocol {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }

    func execute(book: Book) {
        repository.add(book)
    }
}
