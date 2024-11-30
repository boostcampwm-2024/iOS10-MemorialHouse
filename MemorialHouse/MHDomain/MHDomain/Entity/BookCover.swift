import MHFoundation

public struct BookCover: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let imageURL: String?
    public let color: BookColor
    public let category: String?
    public let favorite: Bool
    
    public init(
        id: UUID = .init(),
        title: String,
        imageURL: String?,
        color: BookColor,
        category: String?,
        favorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.color = color
        self.category = category
        self.favorite = favorite
    }
    
    public static func == (lhs: BookCover, rhs: BookCover) -> Bool {
        lhs.id == rhs.id
    }
}
