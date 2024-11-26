import MHFoundation
import MHDomain

public struct BookCoverDTO {
    let identifier: UUID
    let title: String
    let imageURL: String?
    let color: String
    let category: String?
    let favorite: Bool
    
    func toBookCover() -> BookCover? {
        guard let color = BookColor(rawValue: self.color) else { return nil }
        
        return BookCover(
            identifier: self.identifier,
            title: self.title,
            imageURL: self.imageURL,
            color: color,
            category: self.category,
            favorite: self.favorite
        )
    }
}
