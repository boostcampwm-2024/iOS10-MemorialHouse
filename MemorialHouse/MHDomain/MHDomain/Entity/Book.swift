import Foundation

public struct Book: Identifiable {
    public let id: UUID
    public let index: [Int]
    public let pages: [Page]
    
    public init(id: UUID, index: [Int], pages: [Page]) {
        self.id = id
        self.index = index
        self.pages = pages
    }
}
