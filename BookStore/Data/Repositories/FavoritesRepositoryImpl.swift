import Foundation

/// Persistencia con UserDefaults + Codable: alcance suficiente para una lista
/// simple de libros favoritos, sin necesidad de las capacidades relacionales
/// de CoreData. Decisión documentada en ARCHITECTURE.md.
final class FavoritesRepositoryImpl: FavoritesRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let storageKey = "com.slopezg96.bookstore.favorites"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getFavorites() -> [Book] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([Book].self, from: data)) ?? []
    }

    func isFavorite(bookID: String) -> Bool {
        getFavorites().contains { $0.id == bookID }
    }

    func toggleFavorite(_ book: Book) {
        var favorites = getFavorites()
        if let index = favorites.firstIndex(where: { $0.id == book.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(book)
        }
        save(favorites)
    }

    private func save(_ favorites: [Book]) {
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
