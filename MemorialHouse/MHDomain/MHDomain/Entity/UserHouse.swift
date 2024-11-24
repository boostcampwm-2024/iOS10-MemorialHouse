public struct MemorialHouse: Equatable, Sendable {
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
    
    public static func == (lhs: MemorialHouse, rhs: MemorialHouse) -> Bool {
        lhs.name == rhs.name
        && lhs.categories == rhs.categories
        && lhs.bookCovers == rhs.bookCovers
    }
}
