import MHFoundation
import MHDomain
import MHCore

public struct LocalBookCoverRepository: BookCoverRepository {
    private let storage: BookCoverStorage
    
    public init(storage: BookCoverStorage) {
        self.storage = storage
    }
    
    public func create(bookCover: BookCover) async {
        let bookCoverDTO = BookCoverDTO(
            id: bookCover.id,
            title: bookCover.title,
            imageURL: bookCover.imageURL,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        await storage.create(data: bookCoverDTO)
    }
    
    public func fetchAllBookCovers() async -> [BookCover] {
        let result = await storage.fetch()
        
        switch result {
        case .success(let bookCoverDTOs):
            return bookCoverDTOs.compactMap { $0.toBookCover() }
        case .failure(let failure):
            MHLogger.debug("\(failure.description)")
        }
        
        return []
    }
    
    public func fetchBookCover(with id: UUID) async -> BookCover? {
        let result = await storage.fetch()
        
        switch result {
        case .success(let bookCoverDTOs):
            let bookCoverDTO = bookCoverDTOs.filter({ $0.id == id }).first
            return bookCoverDTO?.toBookCover()
        case .failure(let failure):
            MHLogger.debug("\(failure.description)")
        }
        
        return nil
    }
    
    public func update(id: UUID, bookCover: BookCover) async {
        let bookCoverDTO = BookCoverDTO(
            id: bookCover.id,
            title: bookCover.title,
            imageURL: bookCover.imageURL,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        await storage.update(with: id, data: bookCoverDTO)
    }
    
    public func deleteBookCover(_ id: UUID) async {
        await storage.delete(with: id)
    }
}
