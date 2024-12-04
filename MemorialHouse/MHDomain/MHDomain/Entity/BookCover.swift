import MHFoundation

public struct BookCover: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let order: Int
    public let title: String
    public let imageData: Data?
    public let color: BookColor
    public let category: String?
    public let favorite: Bool
    
    public init(
        id: UUID = .init(),
        order: Int,
        title: String,
        imageData: Data?,
        color: BookColor,
        category: String?,
        favorite: Bool = false
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.imageData = imageData
        self.color = color
        self.category = category
        self.favorite = favorite
    }
    
    public static func == (lhs: BookCover, rhs: BookCover) -> Bool {
        lhs.id == rhs.id
    }
}
