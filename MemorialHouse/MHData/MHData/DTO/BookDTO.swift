import MHFoundation
import MHDomain

public struct BookDTO {
    let id: UUID
    let pages: [PageDTO]
    
    public init(id: UUID, pages: [PageDTO]) {
        self.id = id
        self.pages = pages
    }
    
    func convertToBook() -> Book {
        return Book(
            id: self.id,
            pages: self.pages.map { $0.convertToPage() }
        )
    }
}
