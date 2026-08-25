protocol FavoritesRepositoryProtocol {
    func getFavorites() -> [Book]
    func isFavorite(bookID: String) -> Bool
    func toggleFavorite(_ book: Book)
}
