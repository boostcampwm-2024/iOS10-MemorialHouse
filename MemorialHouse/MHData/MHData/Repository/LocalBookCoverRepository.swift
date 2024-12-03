import MHFoundation
import MHDomain
import MHCore

public struct LocalBookCoverRepository: BookCoverRepository {    
    private let storage: BookCoverStorage
    
    public init(storage: BookCoverStorage) {
        self.storage = storage
    }
    
    public func createBookCover(with bookCover: BookCover) async -> Result<Void, MHDataError> {
        let bookCoverDTO = BookCoverDTO(
            id: bookCover.id,
            order: bookCover.order,
            title: bookCover.title,
            imageData: bookCover.imageData,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        return await storage.create(data: bookCoverDTO)
    }
    
    public func fetchBookCover(with id: UUID) async -> Result<BookCover?, MHDataError> {
        let result = await storage.fetch()
        
        switch result {
        case .success(let bookCoverDTOs):
            let bookCoverDTO = bookCoverDTOs.filter({ $0.id == id }).first
            return .success(bookCoverDTO?.convertToBookCover())
        case .failure(let failure):
            MHLogger.debug("\(failure.description)")
            return .failure(failure)
        }
    }
    
    public func fetchAllBookCovers() async -> Result<[BookCover], MHDataError> {
        let result = await storage.fetch()
        
        switch result {
        case .success(let bookCoverDTOs):
            return .success(bookCoverDTOs.compactMap { $0.convertToBookCover() })
        case .failure(let failure):
            MHLogger.debug("\(failure.description)")
            return .failure(failure)
        }
    }
    
    public func updateBookCover(id: UUID, with bookCover: BookCover) async -> Result<Void, MHDataError> {
        let bookCoverDTO = BookCoverDTO(
            id: bookCover.id,
            order: bookCover.order,
            title: bookCover.title,
            imageData: bookCover.imageData,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        return await storage.update(with: id, data: bookCoverDTO)
    }
    
    public func deleteBookCover(id: UUID) async -> Result<Void, MHDataError> {
        return await storage.delete(with: id)
    }
}
