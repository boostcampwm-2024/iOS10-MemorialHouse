import MHFoundation
import MHDomain
import MHCore

public struct LocalBookRepository: BookRepository {
    private let storage: BookStorage
    
    public init(storage: BookStorage) {
        self.storage = storage
    }
    
    public func create(book: Book) async -> Result<Void, MHDataError> {
        let bookDTO = mappingBookToDTO(book)
        
        return await storage.create(data: bookDTO)
    }
    public func fetch(bookID id: UUID) async -> Result<Book, MHDataError> {
        let result = await storage.fetch(with: id)
        
        switch result {
        case let .success(bookDTO):
            return .success(bookDTO.toBook())
        case let .failure(failure):
            MHLogger.debug("\(failure.description)")
            return .failure(failure)
        }
    }
    public func update(bookID id: UUID, to book: Book) async -> Result<Void, MHDataError> {
        let bookDTO = mappingBookToDTO(book)
        
        return await storage.update(with: id, data: bookDTO)
    }
    public func delete(bookID id: UUID) async -> Result<Void, MHDataError> {
        return await storage.delete(with: id)
    }
    
    private func mappingBookToDTO(_ book: Book) -> BookDTO {
        let pages = book.pages.map { mappingPageToDTO($0) }
        return BookDTO(
            id: book.id,
            title: book.title,
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
        let attributes = try? JSONSerialization.data(withJSONObject: description.attributes ?? [:], options: [])
        
        return MediaDescriptionDTO(
            id: description.id,
            type: description.type.rawValue,
            attributes: attributes
        )
    }
}
