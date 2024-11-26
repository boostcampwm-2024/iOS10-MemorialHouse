import MHFoundation
import MHDomain
import MHCore

public struct LocalBookRepository: BookRepository {
    private let storage: BookStorage
    
    public init(storage: BookStorage) {
        self.storage = storage
    }
    
    public func create(book: Book) async {
        let bookDTO = mappingBookToDTO(book)
        
        _ = await storage.create(data: bookDTO)
    }
    public func fetchBook(with id: UUID) async -> Book? {
        let result = await storage.fetch(with: id)
        
        switch result {
        case .success(let bookDTO):
            return bookDTO.toBook()
        case .failure(let failure):
            MHLogger.debug("\(failure.description)")
        }
        
        return nil
    }
    public func update(id: UUID, book: Book) async {
        let bookDTO = mappingBookToDTO(book)
        
        _ = await storage.update(with: id, data: bookDTO)
    }
    public func deleteBook(_ id: UUID) async {
        _ = await storage.delete(with: id)
    }
    
    private func mappingBookToDTO(_ book: Book) -> BookDTO {
        let pages = book.pages.map { mappingPageToDTO($0) }
        return BookDTO(
            id: book.id,
            index: book.index,
            pages: pages
        )
    }
    private func mappingPageToDTO(_ page: Page) -> PageDTO {
        let meatadata = page.metadata
            .compactMapValues { mappingMediaDescriptionToDTO($0) }
        
        return PageDTO(
            id: page.id,
            metadata: meatadata,
            text: page.text
        )
    }
    private func mappingMediaDescriptionToDTO(_ description: MediaDescription) -> MediaDescriptionDTO {
        return MediaDescriptionDTO(
            id: description.id,
            type: description.type.rawValue
        )
    }
}
