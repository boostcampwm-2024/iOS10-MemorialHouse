import MHFoundation
import MHDomain

public struct BookDTO {
    let id: UUID
    let title: String
    let pages: [PageDTO]
    
    public init(
        id: UUID,
        title: String,
        pages: [PageDTO]
    ) {
        self.id = id
        self.title = title
        self.pages = pages
    }
    
    func convertToBook() -> Book {
        return Book(
            id: self.id,
            title: self.title,
            pages: self.pages.map { $0.convertToPage() }
        )
    }
}
