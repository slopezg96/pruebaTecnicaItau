import Foundation

struct CartItem: Identifiable, Equatable {
    let book: Book
    var quantity: Int

    var id: String { book.id }
    var subtotal: Decimal { book.price * Decimal(quantity) }
}
