import SwiftUI

struct CatalogView: View {
    @StateObject private var viewModel: CatalogViewModel
    let container: AppDependencyContainer

    init(viewModel: CatalogViewModel, container: AppDependencyContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
    }

    var body: some View {
        content
            .navigationTitle("Catálogo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showFavoritesOnly.toggle()
                    } label: {
                        Image(systemName: viewModel.showFavoritesOnly ? "heart.fill" : "heart")
                    }
                    .accessibilityLabel(
                        viewModel.showFavoritesOnly ? "Mostrando solo favoritos" : "Mostrar solo favoritos"
                    )
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        CartView(viewModel: container.cartViewModel)
                    } label: {
                        Image(systemName: "cart")
                    }
                    .accessibilityLabel("Ver carrito")
                }
            }
            .task {
                if case .loading = viewModel.state {
                    await viewModel.load()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingView(message: "Cargando catálogo...")
        case .loaded(let books):
            List(books) { book in
                NavigationLink {
                    BookDetailView(viewModel: container.makeDetailViewModel(book: book))
                } label: {
                    BookRowView(book: book, isFavorite: viewModel.isFavorite(book))
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        viewModel.toggleFavorite(book)
                    } label: {
                        Label(
                            viewModel.isFavorite(book) ? "Quitar de favoritos" : "Agregar a favoritos",
                            systemImage: viewModel.isFavorite(book) ? "heart.slash" : "heart"
                        )
                    }
                    .tint(.red)
                }
            }
            .listStyle(.plain)
            .refreshable { await viewModel.refresh() }
        case .empty:
            EmptyStateView(message: viewModel.showFavoritesOnly
                ? "Aún no marcaste libros como favoritos."
                : "No hay libros disponibles en este momento.")
        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }
}
