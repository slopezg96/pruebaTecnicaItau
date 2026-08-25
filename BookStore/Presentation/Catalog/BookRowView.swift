import SwiftUI

struct BookRowView: View {
    let book: Book
    let isFavorite: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(book.price, format: .currency(code: book.currencyCode))
                    .font(.subheadline)
            }
            Spacer()
            if isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .accessibilityLabel("Favorito")
            }
        }
        .padding(.vertical, 4)
    }
}
