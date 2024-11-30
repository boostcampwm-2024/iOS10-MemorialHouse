import MHFoundation
import MHDomain

public struct BookCoverDTO {
    let id: UUID
    let title: String
    let imageURL: String?
    let color: String
    let category: String?
    let favorite: Bool
    
    public init(
        id: UUID,
        title: String,
        imageURL: String?,
        color: String,
        category: String?,
        favorite: Bool
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.color = color
        self.category = category
        self.favorite = favorite
    }
    
    func convertToBookCover() -> BookCover? {
        guard let color = BookColor(rawValue: self.color) else { return nil }
        
        return BookCover(
            id: self.id,
            title: self.title,
            imageURL: self.imageURL,
            color: color,
            category: self.category,
            favorite: self.favorite
        )
    }
}
