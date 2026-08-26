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
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(viewModel.book.author)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Text(viewModel.book.price, format: .currency(code: viewModel.book.currencyCode))
                        .font(.title3)
                    Text(viewModel.book.bookDescription)
                        .font(.body)
                        .padding(.top, 8)
                }
                .padding(.horizontal)

                addToCartButton
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(viewModel.book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                }
                .accessibilityLabel(viewModel.isFavorite ? "Quitar de favoritos" : "Agregar a favoritos")
            }
        }
        .alert("Agregado al carrito", isPresented: $showAddedToCartConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }

    private var addToCartButton: some View {
        Button {
            viewModel.addToCart()
            showAddedToCartConfirmation = true
        } label: {
            Label("Agregar al carrito", systemImage: "cart.badge.plus")
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
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
