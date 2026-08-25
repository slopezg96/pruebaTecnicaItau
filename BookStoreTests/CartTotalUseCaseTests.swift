import XCTest
@testable import BookStore

final class CartTotalUseCaseTests: XCTestCase {
    func test_execute_sumsSubtotalsAcrossItems() {
        let sut = CartTotalUseCase()
        let items = [
            CartItem(book: .fixture(id: "1", price: 10), quantity: 2),
            CartItem(book: .fixture(id: "2", price: 5.5), quantity: 1)
        ]

        let total = sut.execute(items: items)

        XCTAssertEqual(total, Decimal(25.5))
    }

    func test_execute_emptyItems_returnsZero() {
        let sut = CartTotalUseCase()

        XCTAssertEqual(sut.execute(items: []), Decimal(0))
    }
}
