import Foundation

/// API pública del XCFramework: cualquier consumidor (la app) depende solo de este
/// protocolo, nunca de la implementación concreta basada en URLSession.
public protocol NetworkClientProtocol: Sendable {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
