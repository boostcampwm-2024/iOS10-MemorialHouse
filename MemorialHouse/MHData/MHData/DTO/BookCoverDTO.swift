import MHFoundation
import MHDomain

public struct BookCoverDTO {
    let identifier: UUID
    let order: Int
    let title: String
    let imageURL: String?
    let color: String
    let category: String?
    let favorite: Bool
    
    public init(
        identifier: UUID,
        order: Int,
        title: String,
        imageURL: String?,
        color: String,
        category: String?,
        favorite: Bool
    ) {
        self.identifier = identifier
        self.order = order
        self.title = title
        self.imageURL = imageURL
        self.color = color
        self.category = category
        self.favorite = favorite
    }
    
    func convertToBookCover() -> BookCover? {
        guard let color = BookColor(rawValue: self.color) else { return nil }
        
        return BookCover(
            identifier: self.identifier,
            order: self.order,
            title: self.title,
            imageURL: self.imageURL,
            color: color,
            category: self.category,
            favorite: self.favorite
        )
    }
}
