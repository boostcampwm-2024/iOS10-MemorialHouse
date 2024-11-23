import MHFoundation
import MHDomain
import MHCore

public final class DefaultBookCoverRepository: BookCoverRepository {
    
    private let dataSource: CoreDataSource
    
    public init(dataSource: CoreDataSource) {
        self.dataSource = dataSource
    }
    
    public func fetchAllBookCovers() async -> [BookCover] {
        let result = await dataSource.fetch()
        
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
    
    public func fetchBookCover(with id: UUID) -> BookCover? {
        let result = dataSource.fetchBookCover(with: id)
        
        switch result {
        case .success(let bookCoverDTO):
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
    
    public func deleteBookCover(_ id: UUID) {
        let result =  dataSource.deleteBookCover(with: id)
    }
    
    public func create(bookCover: BookCover) {
        let bookCoverDTO = BookCoverDTO(
            identifier: bookCover.identifier,
            title: bookCover.title,
            imageURL: bookCover.imageURL,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        let result =  dataSource.create(bookCover: bookCoverDTO)
    }
    
    public func update(id: UUID, bookCover: BookCover) {
        let bookCoverDTO = BookCoverDTO(
            identifier: bookCover.identifier,
            title: bookCover.title,
            imageURL: bookCover.imageURL,
            color: bookCover.color.rawValue,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
        let result =  dataSource.update(id: id, bookCover: bookCoverDTO)
    }
}
