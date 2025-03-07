import Foundation
import MHDomain
import MHCore

public struct LocalBookCoverRepository: BookCoverRepository {    
    private let storage: BookCoverStorage
    
    public init(storage: BookCoverStorage) {
        self.storage = storage
    }
    
    public func createBookCover(with bookCover: BookCover) throws {
        let bookCoverDTO = BookCoverDTO(
            id: bookCover.id,
            order: bookCover.order,
            title: bookCover.title,
            imageData: bookCover.imageData,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        try storage.create(data: bookCoverDTO)
    }
    
    public func fetchBookCover(with id: UUID) throws -> BookCover? {
        let bookCoverEntities = try storage.fetch()
        let bookCoverEntity = bookCoverEntities.filter({ $0.id == id }).first
        return bookCoverEntity?.convertToBookCover()
    }
    
    public func fetchAllBookCovers() throws -> [BookCover] {
        let bookCoverEntities = try storage.fetch()
        return bookCoverEntities.compactMap { $0.convertToBookCover() }
    }
    
    public func updateBookCover(id: UUID, with bookCover: BookCover) throws {
        let bookCoverDTO = BookCoverDTO(
            id: bookCover.id,
            order: bookCover.order,
            title: bookCover.title,
            imageData: bookCover.imageData,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        try storage.update(with: id, data: bookCoverDTO)
    }
    
    public func deleteBookCover(id: UUID) throws {
        try storage.delete(with: id)
    }
}
