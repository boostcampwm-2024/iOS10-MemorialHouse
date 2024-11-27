import Foundation

public struct Book: Identifiable, Sendable {
    public let id: UUID
    public let pages: [Page]
    
    public init(
        id: UUID = .init(),
        pages: [Page]
    ) {
        self.id = id
        self.pages = pages
    }
}
