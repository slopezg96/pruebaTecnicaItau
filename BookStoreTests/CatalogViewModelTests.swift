import XCTest
@testable import BookStore

@MainActor
final class CatalogViewModelTests: XCTestCase {
    func test_load_success_setsLoadedState() async {
        let books = [Book.fixture(id: "1"), Book.fixture(id: "2")]
        let sut = makeSUT(getBooksResult: .success(books))

        await sut.load()

        guard case .loaded(let loadedBooks) = sut.state else {
            return XCTFail("Se esperaba estado .loaded, se obtuvo \(sut.state)")
        }
        XCTAssertEqual(loadedBooks, books)
    }

    func test_load_emptyResult_setsEmptyState() async {
        let sut = makeSUT(getBooksResult: .success([]))

        await sut.load()

        XCTAssertEqual(sut.state, .empty)
    }

    func test_load_failure_setsErrorState() async {
        let sut = makeSUT(getBooksResult: .failure(NSError(domain: "test", code: 1)))

        await sut.load()

        guard case .error = sut.state else {
            return XCTFail("Se esperaba estado .error, se obtuvo \(sut.state)")
        }
    }

    func test_showFavoritesOnly_filtersListByFavorites() async {
        let favoriteBook = Book.fixture(id: "fav")
        let otherBook = Book.fixture(id: "other")
        let favoritesRepository = FavoritesRepositorySpy()
        favoritesRepository.favoriteIDs = [favoriteBook.id]
        let sut = makeSUT(
            getBooksResult: .success([favoriteBook, otherBook]),
            favoritesRepository: favoritesRepository
        )
        await sut.load()

        sut.showFavoritesOnly = true

        guard case .loaded(let books) = sut.state else {
            return XCTFail("Se esperaba estado .loaded, se obtuvo \(sut.state)")
        }
        XCTAssertEqual(books, [favoriteBook])
    }

    private func makeSUT(
        getBooksResult: Result<[Book], Error>,
        favoritesRepository: FavoritesRepositorySpy = FavoritesRepositorySpy()
    ) -> CatalogViewModel {
        CatalogViewModel(
            getBooksUseCase: GetBooksUseCaseStub(result: getBooksResult),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favoritesRepository),
            favoritesRepository: favoritesRepository
        )
    }
}

private struct GetBooksUseCaseStub: GetBooksUseCaseProtocol {
    let result: Result<[Book], Error>

    func execute() async throws -> [Book] {
        try result.get()
    }
}

private final class FavoritesRepositorySpy: FavoritesRepositoryProtocol {
    var favoriteIDs: Set<String> = []

    func getFavorites() -> [Book] { [] }

    func isFavorite(bookID: String) -> Bool {
        favoriteIDs.contains(bookID)
    }

    func toggleFavorite(_ book: Book) {
        if favoriteIDs.contains(book.id) {
            favoriteIDs.remove(book.id)
        } else {
            favoriteIDs.insert(book.id)
        }
    }
}
