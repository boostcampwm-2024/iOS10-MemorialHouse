import Foundation

public struct Book: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let pages: [Page]
    
    public init(
        id: UUID,
        title: String,
        pages: [Page]
    ) {
        self.id = id
        self.title = title
        self.pages = pages
    }
}
