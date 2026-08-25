protocol GetBooksUseCaseProtocol {
    func execute() async throws -> [Book]
}

final class GetBooksUseCase: GetBooksUseCaseProtocol {
    private let repository: BooksRepositoryProtocol

    init(repository: BooksRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Book] {
        try await repository.fetchCatalog()
    }
}
