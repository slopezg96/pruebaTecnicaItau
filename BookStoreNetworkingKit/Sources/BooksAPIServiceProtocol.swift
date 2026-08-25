import Foundation

public protocol BooksAPIServiceProtocol: Sendable {
    func searchBooks(query: String, maxResults: Int) async throws -> GoogleBooksVolumesResponseDTO
}

public final class GoogleBooksAPIService: BooksAPIServiceProtocol {
    private let networkClient: NetworkClientProtocol
    private let baseURL: String

    public init(networkClient: NetworkClientProtocol = URLSessionNetworkClient(), baseURL: String = "https://www.googleapis.com") {
        self.networkClient = networkClient
        self.baseURL = baseURL
    }

    public func searchBooks(query: String, maxResults: Int) async throws -> GoogleBooksVolumesResponseDTO {
        let endpoint = Endpoint(
            baseURL: baseURL,
            path: "/books/v1/volumes",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "maxResults", value: String(maxResults))
            ]
        )
        return try await networkClient.send(endpoint)
    }
}
