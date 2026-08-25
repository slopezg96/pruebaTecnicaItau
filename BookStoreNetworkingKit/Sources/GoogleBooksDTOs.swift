import Foundation

/// Modelos de respuesta de la Google Books API (parseo vive dentro del XCFramework).
/// El módulo de la app los consume y los mapea a entidades de Domain vía su propio
/// mapper en la capa Data, sin que Domain dependa de este framework.
public struct GoogleBooksVolumesResponseDTO: Decodable, Sendable {
    public let items: [GoogleBooksVolumeDTO]?
}

public struct GoogleBooksVolumeDTO: Decodable, Sendable {
    public let id: String
    public let volumeInfo: VolumeInfoDTO
    public let saleInfo: SaleInfoDTO?
}

public struct VolumeInfoDTO: Decodable, Sendable {
    public let title: String
    public let authors: [String]?
    public let description: String?
    public let imageLinks: ImageLinksDTO?
}

public struct ImageLinksDTO: Decodable, Sendable {
    public let thumbnail: String?
    public let smallThumbnail: String?
}

public struct SaleInfoDTO: Decodable, Sendable {
    public let listPrice: PriceDTO?
}

public struct PriceDTO: Decodable, Sendable {
    public let amount: Double
    public let currencyCode: String
}
