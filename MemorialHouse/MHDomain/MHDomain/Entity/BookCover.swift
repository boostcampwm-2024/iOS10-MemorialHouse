import MHFoundation

public struct BookCover: Sendable {
    public let identifier = UUID()
    public let title: String
    public let imageURL: String
    public let color: BookColor
    public let category: String
    public let favorite: Bool
    
    public init(
        title: String,
        imageURL: String,
        color: BookColor,
        category: String,
        favorite: Bool = false
    ) {
        self.title = title
        self.imageURL = imageURL
        self.color = color
        self.category = category
        self.favorite = favorite
    }
}
