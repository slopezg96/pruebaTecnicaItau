protocol CartRepositoryProtocol {
    func getItems() -> [CartItem]
    func add(_ book: Book)
    func remove(bookID: String)
}
