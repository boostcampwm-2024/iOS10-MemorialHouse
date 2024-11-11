// TODO: 지금 피그잼의 BookCover에서 세분화할 필요성이 느껴짐 (MHBook은 딱 아래 정도만 필요한듯)
public enum BookType {
    case beige
    case blue
    case green
    case orange
    case pink
}

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
