import MHFoundation

public struct BookCover {
    public let bookIdentifer = UUID()
    public let title: String
    public let imageURL: String
    public let bookColor: BookColor
    public let category: String
    public let isLike: Bool
    
    public init(
        title: String,
        imageURL: String,
        bookColor: BookColor,
        category: String,
        isLike: Bool = false
    ) {
        self.title = title
        self.imageURL = imageURL
        self.bookColor = bookColor
        self.category = category
        self.isLike = isLike
    }
}
