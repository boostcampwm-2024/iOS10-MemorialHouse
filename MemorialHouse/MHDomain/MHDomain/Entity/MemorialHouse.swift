public struct MemorialHouse: Sendable {
    public let name: String
    public let categories: [String]
    public let bookCovers: [BookCover]
    
    public init(
        name: String,
        categories: [String],
        bookCovers: [BookCover]
    ) {
        self.name = name
        self.categories = categories
        self.bookCovers = bookCovers
    }
}
