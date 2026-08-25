import XCTest
@testable import BookStore

final class FavoritesRepositoryImplTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var sut: FavoritesRepositoryImpl!

    private let suiteName = "com.slopezg96.bookstore.tests.favorites"

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        sut = FavoritesRepositoryImpl(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        sut = nil
        super.tearDown()
    }

    func test_toggleFavorite_addsAndRemovesBook() {
        let book = Book.fixture(id: "1")

        sut.toggleFavorite(book)
        XCTAssertTrue(sut.isFavorite(bookID: book.id))

        sut.toggleFavorite(book)
        XCTAssertFalse(sut.isFavorite(bookID: book.id))
    }

    func test_favorites_persistAcrossRepositoryInstances() {
        let book = Book.fixture(id: "persisted")
        sut.toggleFavorite(book)

        let newInstance = FavoritesRepositoryImpl(userDefaults: userDefaults)

        XCTAssertTrue(newInstance.isFavorite(bookID: book.id))
    }
}
