import Foundation

public struct MediaDescription: Identifiable, Sendable {
    public let id: UUID
    public let type: MediaType

    public init(
        id: UUID = .init(),
        type: MediaType
    ) {
        self.id = id
        self.type = type
    }
}
