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
