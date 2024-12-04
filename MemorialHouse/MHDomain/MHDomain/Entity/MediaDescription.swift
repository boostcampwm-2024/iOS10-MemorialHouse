import Foundation

public struct MediaDescription: Identifiable, Sendable {
    public let id: UUID
    public let type: MediaType
    public let attributes: [String: any Sendable]?

    public init(
        id: UUID = .init(),
        type: MediaType,
        attributes: [String: any Sendable]? = nil
    ) {
        self.id = id
        self.type = type
        self.attributes = attributes
    }
}
