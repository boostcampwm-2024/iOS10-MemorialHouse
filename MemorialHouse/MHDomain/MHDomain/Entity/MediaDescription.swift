import Foundation

public struct MediaDescription: Identifiable {
    public let id: UUID
    public let type: MediaType

    public init(
        id: UUID,
        type: MediaType
    ) {
        self.id = id
        self.type = type
    }
}
