import MHFoundation
import MHDomain
import MHCore

public struct LocalBookCoverRepository: BookCoverRepository {
    private let storage: BookCoverStorage
    
    public init(storage: BookCoverStorage) {
        self.storage = storage
    }
    
    public func fetchAllBookCovers() async -> [BookCover] {
        let result = await storage.fetch()
        
        switch result {
        case .success(let bookCoverDTOs):
            return bookCoverDTOs.compactMap { (dto: BookCoverDTO) -> BookCover? in
                guard let color = BookColor(rawValue: dto.color) else { return nil }
                return BookCover(
                    identifier: dto.identifier,
                    title: dto.title,
                    imageURL: dto.imageURL,
                    color: color,
                    category: dto.category,
                    favorite: dto.favorite
                )
            }
        case .failure(let failure):
            MHLogger.debug("\(failure.description)")
        }
        
        return []
    }
    
    public func fetchBookCover(with id: UUID) async -> BookCover? {
        let result = await storage.fetch()
        
        switch result {
        case .success(let bookCoverDTOs):
            let bookCoverDTO = bookCoverDTOs.filter({ $0.identifier == id }).first
            guard let bookCoverDTO,
                  let color = BookColor(rawValue: bookCoverDTO.color) else { return nil }
            
            return BookCover(
                identifier: bookCoverDTO.identifier,
                title: bookCoverDTO.title,
                imageURL: bookCoverDTO.imageURL,
                color: color,
                category: bookCoverDTO.category,
                favorite: bookCoverDTO.favorite
            )
        case .failure(let failure):
            MHLogger.debug("\(failure.description)")
        }
        
        return nil
    }
    
    public func deleteBookCover(_ id: UUID) async {
        await storage.delete(with: id)
    }
    
    public func create(bookCover: BookCover) async {
        let bookCoverDTO = BookCoverDTO(
            identifier: bookCover.identifier,
            title: bookCover.title,
            imageURL: bookCover.imageURL,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        await storage.create(data: bookCoverDTO)
    }
    
    public func update(id: UUID, bookCover: BookCover) async {
        let bookCoverDTO = BookCoverDTO(
            identifier: bookCover.identifier,
            title: bookCover.title,
            imageURL: bookCover.imageURL,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        await storage.update(with: id, data: bookCoverDTO)
    }
}
