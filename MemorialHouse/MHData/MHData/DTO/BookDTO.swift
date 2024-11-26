import MHFoundation
import MHDomain

public struct BookDTO {
    let id: UUID
    let pages: [PageDTO]
    
    func toBook() -> Book {
        return Book(
            id: self.id,
            pages: self.pages.map { $0.toPage() }
        )
    }
}
