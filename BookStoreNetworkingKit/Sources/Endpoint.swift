import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
}

public struct Endpoint: Sendable {
    public let baseURL: String
    public let path: String
    public let queryItems: [URLQueryItem]
    public let method: HTTPMethod

    public init(baseURL: String, path: String, queryItems: [URLQueryItem] = [], method: HTTPMethod = .get) {
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
        self.method = method
    }

    public var url: URL? {
        var components = URLComponents(string: baseURL + path)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }
}
