import Foundation
@testable import BookStore

extension Book {
    static func fixture(
        id: String = "fixture-id",
        title: String = "Fixture Title",
        author: String = "Fixture Author",
        price: Decimal = 9.99
    ) -> Book {
        Book(
            id: id,
            title: title,
            author: author,
            price: price,
            bookDescription: "Fixture description",
            coverImageURL: nil
        )
    }
}
