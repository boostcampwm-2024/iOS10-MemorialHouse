import MHFoundation
import MHCore
import CoreData

public final class CoreDataBookCategoryStorage {
    private let coreDataStorage: CoreDataStorage
    
    public init(coreDataStorage: CoreDataStorage) {
        self.coreDataStorage = coreDataStorage
    }
}

extension CoreDataBookCategoryStorage: BookCategoryStorage {
    public func create(with category: BookCategoryDTO) async -> Result<Void, MHDataError> {
        return await coreDataStorage.performDatabaseTask { context in
            guard let entity = NSEntityDescription.entity(forEntityName: "BookCategoryEntity", in: context) else {
                throw MHDataError.noSuchEntity(key: "BookCategoryEntity")
            }
            let bookCategory = NSManagedObject(entity: entity, insertInto: context)
            bookCategory.setValue(category.order, forKey: "order")
            bookCategory.setValue(category.name, forKey: "name")
            
            try context.save()
        }
    }
    
    public func fetch() async -> Result<[BookCategoryDTO], MHDataError> {
        return await coreDataStorage.performDatabaseTask { [weak self] context in
            let request = BookCategoryEntity.fetchRequest()
            let bookCategoryEntities = try context.fetch(request)
            
            return bookCategoryEntities.compactMap { self?.coreBookCategoryToDTO($0) }
        }
    }
    
    public func update(oldName: String, with category: BookCategoryDTO) async -> Result<Void, MHDataError> {
        return await coreDataStorage.performDatabaseTask { context in
            let request = BookCategoryEntity.fetchRequest()
            if let entity = try context.fetch(request).first(where: { $0.name == oldName }) {
                entity.setValue(category.name, forKey: "name")
                entity.setValue(category.order, forKey: "order")
                
                try context.save()
            }
        }
    }
    
    public func delete(with categoryName: String) async -> Result<Void, MHDataError> {
        return await coreDataStorage.performDatabaseTask { context in
            let request = BookCategoryEntity.fetchRequest()
            if let entity = try context.fetch(request).first(where: { $0.name == categoryName }) {
                context.delete(entity)
                
                try context.save()
            }
        }
    }
}

// MARK: - Mapper
extension CoreDataBookCategoryStorage {
    func coreBookCategoryToDTO(_ bookCategory: BookCategoryEntity) -> BookCategoryDTO? {
        guard let name = bookCategory.name else { return nil }
        let order = Int(bookCategory.order)
        
        return BookCategoryDTO(
            order: order,
            name: name
        )
    }
}
