
public struct BookCover {
    public let title: String
    public let imageURL: String
    public let bookType: BookType
    
    public init(
        title: String,
        imageURL: String,
        bookType: BookType
    ) {
        self.title = title
        self.imageURL = imageURL
        self.bookType = bookType
    }
}
