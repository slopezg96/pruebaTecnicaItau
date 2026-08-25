import SwiftUI

struct CatalogView: View {
    @StateObject private var viewModel: CatalogViewModel

    init(viewModel: CatalogViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Catálogo")
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
                    Text(book.title)
                } label: {
                    BookRowView(book: book, isFavorite: viewModel.isFavorite(book))
                }
            }
            .listStyle(.plain)
            .refreshable { await viewModel.refresh() }
        case .empty:
            EmptyStateView(message: "No hay libros disponibles en este momento.")
        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }
}
