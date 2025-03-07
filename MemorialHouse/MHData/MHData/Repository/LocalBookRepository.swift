import Foundation
import MHDomain
import MHCore

public struct LocalBookRepository: BookRepository {
    private let storage: BookStorage
    
    public init(storage: BookStorage) {
        self.storage = storage
    }
    
    public func create(book: Book) async throws {
        let bookDTO = mappingBookToDTO(book)
        try await storage.create(data: bookDTO)
    }
    
    public func fetch(bookID id: UUID) async throws -> Book {
        let bookEntity = try await storage.fetch(with: id)
        return bookEntity.convertToBook()
    }
    
    public func update(bookID id: UUID, to book: Book) async throws {
        let bookDTO = mappingBookToDTO(book)
        try await storage.update(with: id, data: bookDTO)
    }
    
    public func delete(bookID id: UUID) async throws {
        try await storage.delete(with: id)
    }
    
    // MARK: - Mapping
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
