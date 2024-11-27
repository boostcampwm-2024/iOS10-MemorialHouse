import MHFoundation
import MHCore
import CoreData

final class CoreDataBookCoverStorage {
    private let coreDataStorage: CoreDataStorage
    
    init(coreDataStorage: CoreDataStorage) {
        self.coreDataStorage = coreDataStorage
    }
}

extension CoreDataBookCoverStorage: BookCoverStorage {
    func create(data: BookCoverDTO) async -> Result<Void, MHDataError> {
        let context = coreDataStorage.persistentContainer.viewContext
        do {
            try await context.perform {
                guard let entity = NSEntityDescription.entity(forEntityName: "BookCoverEntity", in: context) else {
                    throw MHDataError.noSuchEntity(key: "BookCoverEntity")
                }
                let bookCover = NSManagedObject(entity: entity, insertInto: context)
                bookCover.setValue(data.identifier, forKey: "identifier")
                bookCover.setValue(data.title, forKey: "title")
                bookCover.setValue(data.category, forKey: "category")
                bookCover.setValue(data.color, forKey: "color")
                bookCover.setValue(data.imageURL, forKey: "imageURL")
                bookCover.setValue(data.favorite, forKey: "favorite")
                
                try context.save()
            }
            return .success(())
        } catch let error as MHDataError {
            MHLogger.debug("Error creating book cover: \(error.description)")
            return .failure(error)
        } catch {
            MHLogger.debug("Unknown Error creating book cover: \(error.localizedDescription)")
            return .failure(.createEntityFailure)
        }
    }
    
    func fetch() async -> Result<[BookCoverDTO], MHDataError> {
        let context = coreDataStorage.persistentContainer.viewContext
        do {
            var bookCoverEntities: [BookCoverEntity] = []
            try await context.perform {
                let request = BookCoverEntity.fetchRequest()
                bookCoverEntities = try context.fetch(request)
            }
            let result = bookCoverEntities.compactMap { $0.toBookCoverDTO() }
            return .success(result)
        } catch let error as MHDataError {
            MHLogger.debug("Error fetching book cover: \(error.description)")
            return .failure(error)
        } catch {
            MHLogger.debug("Unknown Error fetching book cover: \(error.localizedDescription)")
            return .failure(.fetchEntityFaliure)
        }
    }
    
    func update(with id: UUID, data: BookCoverDTO) async -> Result<Void, MHDataError> {
        let context = coreDataStorage.persistentContainer.viewContext
        do {
            try await context.perform { [weak self] in
                guard let newEntity = try self?.getEntityByIdentifier(in: context, with: id) else {
                    throw MHDataError.findEntityFailure
                }
                newEntity.setValue(data.identifier, forKey: "identifier")
                newEntity.setValue(data.title, forKey: "title")
                newEntity.setValue(data.category, forKey: "category")
                newEntity.setValue(data.color, forKey: "color")
                newEntity.setValue(data.imageURL, forKey: "imageURL")
                newEntity.setValue(data.favorite, forKey: "favorite")
                
                try context.save()
            }
            return .success(())
        } catch let error as MHDataError {
            MHLogger.debug("Error updating book cover: \(error.description)")
            return .failure(error)
        } catch {
            MHLogger.debug("Unknown Error updating book cover: \(error.localizedDescription)")
            return .failure(.updateEntityFailure)
        }
    }
    
    func delete(with id: UUID) async -> Result<Void, MHDataError> {
        let context = coreDataStorage.persistentContainer.viewContext
        do {
            try await context.perform { [weak self] in
                guard let entity = try self?.getEntityByIdentifier(in: context, with: id) else {
                    throw MHDataError.findEntityFailure
                }
                
                context.delete(entity)
                
                try context.save()
            }
            return .success(())
        } catch let error as MHDataError {
            MHLogger.debug("Error deleting book cover: \(error.description)")
            return .failure(error)
        } catch {
            MHLogger.debug("Unknown Error deleting book cover: \(error.localizedDescription)")
            return .failure(.deleteEntityFailure)
        }
    }
    
    private func getEntityByIdentifier(in context: NSManagedObjectContext, with id: UUID) throws -> BookCoverEntity? {
        let request = BookCoverEntity.fetchRequest()
        
        return try context.fetch(request).first(where: { $0.identifier == id })
    }
}

// MARK: - BookCoverEntity Extension
extension BookCoverEntity {
    func toBookCoverDTO() -> BookCoverDTO? {
        guard let identifier = self.identifier,
              let title = self.title,
              let color = self.color else { return nil }
        
        return BookCoverDTO(
            identifier: identifier,
            title: title,
            imageURL: self.imageURL,
            color: color,
            category: self.category,
            favorite: self.favorite
        )
    }
}
