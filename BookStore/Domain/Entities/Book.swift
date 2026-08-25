import Foundation

/// Entidad de Domain: independiente de cualquier framework (solo Foundation).
/// No incluye estado de favorito: eso es una relación (Book pertenece o no a
/// favoritos) que gestiona `FavoritesRepositoryProtocol`, no un atributo propio
/// del libro.
struct Book: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let author: String
    let price: Decimal
    let currencyCode: String
    let bookDescription: String
    let coverImageURL: URL?

    init(
        id: String,
        title: String,
        author: String,
        price: Decimal,
        currencyCode: String = "USD",
        bookDescription: String,
        coverImageURL: URL?
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.price = price
        self.currencyCode = currencyCode
        self.bookDescription = bookDescription
        self.coverImageURL = coverImageURL
    }
}
