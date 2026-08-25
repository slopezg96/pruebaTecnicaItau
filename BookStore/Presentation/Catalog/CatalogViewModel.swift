import Foundation

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[Book]> = .loading

    private let getBooksUseCase: GetBooksUseCaseProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    init(getBooksUseCase: GetBooksUseCaseProtocol, favoritesRepository: FavoritesRepositoryProtocol) {
        self.getBooksUseCase = getBooksUseCase
        self.favoritesRepository = favoritesRepository
    }

    func load() async {
        state = .loading
        await fetch()
    }

    func refresh() async {
        await fetch()
    }

    func isFavorite(_ book: Book) -> Bool {
        favoritesRepository.isFavorite(bookID: book.id)
    }

    private func fetch() async {
        do {
            let books = try await getBooksUseCase.execute()
            state = books.isEmpty ? .empty : .loaded(books)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
