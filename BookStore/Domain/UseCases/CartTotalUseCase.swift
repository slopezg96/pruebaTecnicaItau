import Foundation

protocol CartTotalUseCaseProtocol {
    func execute(items: [CartItem]) -> Decimal
}

final class CartTotalUseCase: CartTotalUseCaseProtocol {
    func execute(items: [CartItem]) -> Decimal {
        items.reduce(Decimal(0)) { $0 + $1.subtotal }
    }
}
