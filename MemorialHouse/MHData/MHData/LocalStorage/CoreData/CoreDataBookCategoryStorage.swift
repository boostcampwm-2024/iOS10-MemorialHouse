import MHFoundation
import MHCore
import CoreData

final class CoreDataBookCategoryStorage {
    private let coreDataStorage: CoreDataStorage
    
    init(coreDataStorage: CoreDataStorage) {
        self.coreDataStorage = coreDataStorage
    }
    
    private func performDatabaseTask<T>(
        _ task: @escaping (NSManagedObjectContext) throws -> T
    ) async -> Result<T, MHDataError> {
        let context = coreDataStorage.persistentContainer.viewContext
        do {
            return try await context.perform {
                do {
                    return .success(try task(context))
                } catch let error as MHDataError {
                    MHLogger.debug("Core Data 에러: \(error.description)")
                    throw error
                } catch {
                    MHLogger.debug("알 수 없는 Core Data 에러: \(error.localizedDescription)")
                    throw error
                }
            }
        } catch let error as MHDataError {
            return .failure(error)
        } catch {
            return .failure(MHDataError.generalFailure(error))
        }
    }
}

extension CoreDataBookCategoryStorage: BookCategoryStorage {
    func create(with data: BookCategoryDTO) async -> Result<Void, MHDataError> {
        return await performDatabaseTask { context in
            guard let entity = NSEntityDescription.entity(forEntityName: "BookCategoryEntity", in: context) else {
                throw MHDataError.noSuchEntity(key: "BookCategoryEntity")
            }
            let bookCategory = NSManagedObject(entity: entity, insertInto: context)
            bookCategory.setValue(data.order, forKey: "order")
            bookCategory.setValue(data.name, forKey: "name")
            try context.save()
        }
    }
    
    func fetch() async -> Result<[BookCategoryDTO], MHDataError> {
        return await performDatabaseTask { [weak self] context in
            let request = BookCategoryEntity.fetchRequest()
            let bookCategoryEntities = try context.fetch(request)
            return bookCategoryEntities.compactMap { self?.coreBookCategoryToDTO($0) }
        }
    }
    
    func update(with data: BookCategoryDTO) async -> Result<Void, MHDataError> {
        return await performDatabaseTask { context in
            let request = BookCategoryEntity.fetchRequest()
            if let entity = try context.fetch(request).first(where: { $0.name == data.name }) {
                entity.setValue(data.name, forKey: "name")
                entity.setValue(data.order, forKey: "order")
                try context.save()
            }
        }
    }
    
    func delete(with data: BookCategoryDTO) async -> Result<Void, MHDataError> {
        return await performDatabaseTask { context in
            let request = BookCategoryEntity.fetchRequest()
            if let entity = try context.fetch(request).first(where: { $0.name == data.name }) {
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
