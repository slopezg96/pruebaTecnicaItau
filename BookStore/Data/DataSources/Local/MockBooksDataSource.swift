import Foundation

/// Fuente local alternativa al API real (catálogo embebido en JSON), con una
/// latencia simulada para comportarse como una fuente de datos real. Gracias a
/// `BooksRepositoryProtocol` (capa Domain) es intercambiable con la fuente
/// remota sin que Presentation lo note.
protocol LocalBooksDataSourceProtocol {
    func fetchBooks() async throws -> [Book]
}

final class MockBooksDataSource: LocalBooksDataSourceProtocol {
    private let bundle: Bundle
    private let simulatedLatencyNanoseconds: UInt64

    init(bundle: Bundle = .main, simulatedLatencyNanoseconds: UInt64 = 400_000_000) {
        self.bundle = bundle
        self.simulatedLatencyNanoseconds = simulatedLatencyNanoseconds
    }

    func fetchBooks() async throws -> [Book] {
        try await Task.sleep(nanoseconds: simulatedLatencyNanoseconds)

        guard let url = bundle.url(forResource: "mock_books", withExtension: "json") else {
            return []
        }
        let data = try Data(contentsOf: url)
        let dtos = try JSONDecoder().decode([MockBookDTO].self, from: data)
        return dtos.map { $0.toEntity() }
    }
}

private struct MockBookDTO: Decodable {
    let id: String
    let title: String
    let author: String
    let price: Decimal
    let currencyCode: String
    let description: String
    let coverImageURL: String?

    func toEntity() -> Book {
        Book(
            id: id,
            title: title,
            author: author,
            price: price,
            currencyCode: currencyCode,
            bookDescription: description,
            coverImageURL: coverImageURL.flatMap(URL.init(string:))
        )
    }
}
