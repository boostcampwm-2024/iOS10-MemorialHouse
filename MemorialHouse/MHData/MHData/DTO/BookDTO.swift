import MHFoundation
import MHDomain

public struct BookDTO {
    let id: UUID
    let index: [Int]
    let pages: [PageDTO]
    
    func toBook() -> Book {
        return Book(
            id: self.id,
            index: self.index,
            pages: self.pages.map { $0.toPage() }
        )
    }
}
