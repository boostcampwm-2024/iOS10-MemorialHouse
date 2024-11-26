public struct MemorialHouse: Sendable {
    public let name: String
    public let bookCovers: [BookCover]
    
    public init(
        name: String,
        bookCovers: [BookCover]
    ) {
        self.name = name
        self.bookCovers = bookCovers
    }
}
