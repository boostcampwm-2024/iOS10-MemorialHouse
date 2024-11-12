import MHFoundation

public struct BookCover {
    public let bookIdentifer = UUID()
    public let title: String
    public let imageURL: String
    public let bookType: BookColor
    public let category: String
    public let favorite: Bool
    
    public init(
        title: String,
        imageURL: String,
        bookType: BookColor,
        category: String,
        favorite: Bool = false
    ) {
        self.title = title
        self.imageURL = imageURL
        self.bookType = bookType
        self.category = category
        self.favorite = favorite
    }
}
