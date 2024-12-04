import MHFoundation
import MHDomain

public struct BookCoverDTO {
    let id: UUID
    let order: Int
    let title: String
    let imageData: Data?
    let color: String
    let category: String?
    let favorite: Bool
    
    public init(
        id: UUID,
        order: Int,
        title: String,
        imageData: Data?,
        color: String,
        category: String?,
        favorite: Bool
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.imageData = imageData
        self.color = color
        self.category = category
        self.favorite = favorite
    }
    
    func convertToBookCover() -> BookCover? {
        guard let color = BookColor(rawValue: self.color) else { return nil }
        
        return BookCover(
            id: self.id,
            order: self.order,
            title: self.title,
            imageData: self.imageData,
            color: color,
            category: self.category,
            favorite: self.favorite
        )
    }
}
