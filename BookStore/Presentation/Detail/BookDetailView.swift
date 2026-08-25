import SwiftUI

struct BookDetailView: View {
    @StateObject private var viewModel: BookDetailViewModel
    @State private var showAddedToCartConfirmation = false

    init(viewModel: BookDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                coverImage

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.book.title)
                        .font(.title2)
                        .bold()
                    Text(viewModel.book.author)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.book.price, format: .currency(code: viewModel.book.currencyCode))
                        .font(.title3)
                    Text(viewModel.book.bookDescription)
                        .font(.body)
                        .padding(.top, 8)
                }
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Label(
                            viewModel.isFavorite ? "Quitar de favoritos" : "Agregar a favoritos",
                            systemImage: viewModel.isFavorite ? "heart.fill" : "heart"
                        )
                    }
                    .buttonStyle(.bordered)

                    Button {
                        viewModel.addToCart()
                        showAddedToCartConfirmation = true
                    } label: {
                        Label("Agregar al carrito", systemImage: "cart.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(viewModel.book.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Agregado al carrito", isPresented: $showAddedToCartConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var coverImage: some View {
        if let url = viewModel.book.coverImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit)
                case .failure:
                    placeholderCover
                case .empty:
                    ProgressView().frame(height: 220)
                @unknown default:
                    placeholderCover
                }
            }
            .frame(maxHeight: 260)
            .frame(maxWidth: .infinity)
        } else {
            placeholderCover
        }
    }

    private var placeholderCover: some View {
        Image(systemName: "book.closed")
            .font(.system(size: 80))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 220)
            .background(Color(.secondarySystemBackground))
    }
}
