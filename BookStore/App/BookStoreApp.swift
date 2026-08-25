import SwiftUI

@main
struct BookStoreApp: App {
    private let container = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CatalogView(viewModel: container.makeCatalogViewModel())
            }
        }
    }
}
