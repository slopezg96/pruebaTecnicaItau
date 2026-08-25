import XCTest
import BookStoreNetworkingKit
@testable import BookStore

final class BookMapperTests: XCTestCase {
    func test_map_withListPrice_usesRealPriceFromSaleInfo() throws {
        let json = """
        {
            "id": "abc123",
            "volumeInfo": {
                "title": "Some Title",
                "authors": ["Author One", "Author Two"],
                "description": "Some description",
                "imageLinks": { "thumbnail": "http://example.com/cover.jpg" }
            },
            "saleInfo": {
                "listPrice": { "amount": 12.5, "currencyCode": "USD" }
            }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(GoogleBooksVolumeDTO.self, from: json)

        let book = BookMapper.map(dto)

        XCTAssertEqual(book.id, "abc123")
        XCTAssertEqual(book.title, "Some Title")
        XCTAssertEqual(book.author, "Author One, Author Two")
        XCTAssertEqual(book.price, Decimal(12.5))
        XCTAssertEqual(book.currencyCode, "USD")
        XCTAssertEqual(book.coverImageURL, URL(string: "https://example.com/cover.jpg"))
    }

    func test_map_withoutListPrice_derivesDeterministicFallbackPrice() throws {
        let json = """
        {
            "id": "no-price-volume",
            "volumeInfo": { "title": "No Price Book" }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(GoogleBooksVolumeDTO.self, from: json)

        let firstMap = BookMapper.map(dto)
        let secondMap = BookMapper.map(dto)

        XCTAssertEqual(firstMap.price, secondMap.price, "El precio de respaldo debe ser determinista")
        XCTAssertGreaterThan(firstMap.price, 0)
        XCTAssertEqual(firstMap.author, "Autor desconocido")
    }
}
