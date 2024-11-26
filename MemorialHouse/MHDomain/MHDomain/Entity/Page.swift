import Foundation

public struct Page: Identifiable, Sendable {
    public let id: UUID
    public let metadata: [Int: MediaDescription]
    public let text: String
    
    public init(
        id: UUID = .init(),
        metadata: [Int: MediaDescription],
        text: String
    ) {
        self.id = id
        self.metadata = metadata
        self.text = text
    }
}
