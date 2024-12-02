import MHFoundation
import MHCore
import CoreData

public final class CoreDataBookCoverStorage {
    private let coreDataStorage: CoreDataStorage
    
    public init(coreDataStorage: CoreDataStorage) {
        self.coreDataStorage = coreDataStorage
    }
}

extension CoreDataBookCoverStorage: BookCoverStorage {
    public func create(data: BookCoverDTO) async -> Result<Void, MHDataError> {
        return await coreDataStorage.performDatabaseTask { context in
            guard let entity = NSEntityDescription.entity(forEntityName: "BookCoverEntity", in: context) else {
                throw MHDataError.noSuchEntity(key: "BookCoverEntity")
            }
            let bookCover = NSManagedObject(entity: entity, insertInto: context)
            bookCover.setValue(data.id, forKey: "id")
            bookCover.setValue(data.title, forKey: "title")
            bookCover.setValue(data.category, forKey: "category")
            bookCover.setValue(data.color, forKey: "color")
            bookCover.setValue(data.imageURL, forKey: "imageURL")
            bookCover.setValue(data.favorite, forKey: "favorite")
            
            try context.save()
        }
    }
    
    public func fetch() async -> Result<[BookCoverDTO], MHDataError> {
        return await coreDataStorage.performDatabaseTask { [weak self] context in
            let request = BookCoverEntity.fetchRequest()
            let bookCoverEntities = try context.fetch(request)
            return bookCoverEntities.compactMap { self?.coreBookCoverToDTO($0) }
        }
    }
    
    public func update(with id: UUID, data: BookCoverDTO) async -> Result<Void, MHDataError> {
        return await coreDataStorage.performDatabaseTask { [weak self] context in
            guard let newEntity = try self?.getEntityByIdentifier(in: context, with: id) else {
                throw MHDataError.findEntityFailure
            }
            newEntity.setValue(data.id, forKey: "id")
            newEntity.setValue(data.title, forKey: "title")
            newEntity.setValue(data.category, forKey: "category")
            newEntity.setValue(data.color, forKey: "color")
            newEntity.setValue(data.imageURL, forKey: "imageURL")
            newEntity.setValue(data.favorite, forKey: "favorite")
            
            try context.save()
        }
    }
    
    // TODO: 책 커버 삭제 시, 책 내용 모두 삭제되게끔 수정 필요
    public func delete(with id: UUID) async -> Result<Void, MHDataError> {
        return await coreDataStorage.performDatabaseTask { [weak self] context in
            guard let entity = try self?.getEntityByIdentifier(in: context, with: id) else {
                throw MHDataError.findEntityFailure
            }
            context.delete(entity)
            
            try context.save()
        }
    }
    
    private func getEntityByIdentifier(in context: NSManagedObjectContext, with id: UUID) throws -> BookCoverEntity? {
        let request = BookCoverEntity.fetchRequest()
        
        return try context.fetch(request).first(where: { $0.id == id })
    }
}

// MARK: - Mapper
extension CoreDataBookCoverStorage {
    // MARK: - CoreToDTO
    func coreBookCoverToDTO(_ bookCover: BookCoverEntity) -> BookCoverDTO? {
        guard let id = bookCover.id,
              let title = bookCover.title,
              let color = bookCover.color else { return nil }
        
        return BookCoverDTO(
            id: id,
            order: Int(bookCover.order),
            title: title,
            imageURL: bookCover.imageURL,
            color: color,
            category: bookCover.category,
            favorite: bookCover.favorite
        )
    }
}
