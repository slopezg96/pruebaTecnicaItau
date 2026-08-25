/// El carrito no es un requisito de persistencia (punto 3.3 del prompt): vive
/// en memoria mientras la app está abierta. Se inyecta como instancia
/// compartida desde el DI container para sobrevivir a la navegación entre
/// pantallas.
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
