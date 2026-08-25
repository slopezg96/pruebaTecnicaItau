import Foundation

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[Book]> = .loading
    @Published var showFavoritesOnly = false {
        didSet { applyFilter() }
    }

    private let getBooksUseCase: GetBooksUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private var allBooks: [Book] = []

    init(
        getBooksUseCase: GetBooksUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        favoritesRepository: FavoritesRepositoryProtocol
    ) {
        self.getBooksUseCase = getBooksUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
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

    func toggleFavorite(_ book: Book) {
        toggleFavoriteUseCase.execute(book: book)
        applyFilter()
    }

    private func fetch() async {
        do {
            allBooks = try await getBooksUseCase.execute()
            applyFilter()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func applyFilter() {
        let visibleBooks = showFavoritesOnly
            ? allBooks.filter { favoritesRepository.isFavorite(bookID: $0.id) }
            : allBooks
        state = visibleBooks.isEmpty ? .empty : .loaded(visibleBooks)
    }
}
