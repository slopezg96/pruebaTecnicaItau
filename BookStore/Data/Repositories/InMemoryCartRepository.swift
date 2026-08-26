/// Estado del carrito en memoria: vive mientras la app está abierta y no
/// sobrevive a un reinicio. Se inyecta como instancia compartida desde el
/// DI container para sobrevivir a la navegación entre pantallas.
final class InMemoryCartRepository: CartRepositoryProtocol {
    private var items: [CartItem] = []

    func getItems() -> [CartItem] {
        items
    }

    func add(_ book: Book) {
        if let index = items.firstIndex(where: { $0.book.id == book.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(book: book, quantity: 1))
        }
    }

    func remove(bookID: String) {
        items.removeAll { $0.book.id == bookID }
    }
}
