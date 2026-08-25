import Foundation

@MainActor
final class CartViewModel: ObservableObject {
    @Published private(set) var items: [CartItem] = []

    private let cartRepository: CartRepositoryProtocol
    private let removeFromCartUseCase: RemoveFromCartUseCaseProtocol
    private let cartTotalUseCase: CartTotalUseCaseProtocol

    init(
        cartRepository: CartRepositoryProtocol,
        removeFromCartUseCase: RemoveFromCartUseCaseProtocol,
        cartTotalUseCase: CartTotalUseCaseProtocol
    ) {
        self.cartRepository = cartRepository
        self.removeFromCartUseCase = removeFromCartUseCase
        self.cartTotalUseCase = cartTotalUseCase
    }

    var total: Decimal {
        cartTotalUseCase.execute(items: items)
    }

    func refresh() {
        items = cartRepository.getItems()
    }

    func remove(bookID: String) {
        removeFromCartUseCase.execute(bookID: bookID)
        refresh()
    }
}
