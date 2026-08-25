import SwiftUI

struct CartView: View {
    @StateObject private var viewModel: CartViewModel

    init(viewModel: CartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.items.isEmpty {
                EmptyStateView(message: "Tu carrito está vacío.")
            } else {
                List {
                    Section {
                        ForEach(viewModel.items) { item in
                            CartRowView(item: item)
                        }
                        .onDelete(perform: delete)
                    }

                    Section {
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(viewModel.total, format: .currency(code: viewModel.items.first?.book.currencyCode ?? "USD"))
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .navigationTitle("Carrito")
        .task {
            viewModel.refresh()
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            viewModel.remove(bookID: viewModel.items[index].id)
        }
    }
}

private struct CartRowView: View {
    let item: CartItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.book.title)
                    .font(.headline)
                Text("Cantidad: \(item.quantity)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.subtotal, format: .currency(code: item.book.currencyCode))
        }
    }
}
