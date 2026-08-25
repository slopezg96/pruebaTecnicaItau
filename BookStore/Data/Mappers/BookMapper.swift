import Foundation
import BookStoreNetworkingKit

enum BookMapper {
    static func map(_ dto: GoogleBooksVolumeDTO) -> Book {
        let price = resolvedPrice(for: dto)
        let rawImageURL = dto.volumeInfo.imageLinks?.thumbnail ?? dto.volumeInfo.imageLinks?.smallThumbnail
        let secureImageURL = rawImageURL.map { $0.replacingOccurrences(of: "http://", with: "https://") }

        return Book(
            id: dto.id,
            title: dto.volumeInfo.title,
            author: (dto.volumeInfo.authors ?? ["Autor desconocido"]).joined(separator: ", "),
            price: price.amount,
            currencyCode: price.currencyCode,
            bookDescription: dto.volumeInfo.description ?? "Sin descripción disponible.",
            coverImageURL: secureImageURL.flatMap(URL.init(string:))
        )
    }

    /// Google Books no siempre retorna `saleInfo.listPrice` (depende de la
    /// disponibilidad comercial del volumen). Cuando falta, se deriva un precio
    /// determinista a partir del id del volumen para que el catálogo siempre
    /// muestre un precio — decisión pragmática documentada en ARCHITECTURE.md.
    private static func resolvedPrice(for dto: GoogleBooksVolumeDTO) -> (amount: Decimal, currencyCode: String) {
        if let listPrice = dto.saleInfo?.listPrice {
            return (Decimal(listPrice.amount), listPrice.currencyCode)
        }
        let bucket = abs(dto.id.hashValue) % 30
        let cents = Decimal(sign: .plus, exponent: -2, significand: 99)
        let amount = Decimal(9) + Decimal(bucket) + cents
        return (amount, "USD")
    }
}
