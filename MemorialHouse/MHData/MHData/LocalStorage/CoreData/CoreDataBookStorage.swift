import MHFoundation
import MHCore
import CoreData

final class CoreDataBookStorage {
    private let coreDataStorage: CoreDataStorage
    
    init(coreDataStorage: CoreDataStorage) {
        self.coreDataStorage = coreDataStorage
    }
}

extension CoreDataBookStorage: BookStorage {
    func create(data: BookDTO) async -> Result<Void, MHError> {
        let context = coreDataStorage.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "BookEntity", in: context) else {
            return .failure(.DIContainerResolveFailure(key: "BookEntity"))
        }
        
        let book = NSManagedObject(entity: entity, insertInto: context)
        book.setValue(data.id, forKey: "id")
        book.setValue(data.pages, forKey: "pages")
        
        await coreDataStorage.saveContext()
        return .success(())
    }
    func fetch(with id: UUID) async -> Result<BookDTO, MHError> {
        let context = coreDataStorage.persistentContainer.viewContext

        do {
            let bookEntity = try getEntityByIdentifier(in: context, with: id)
            guard let result = bookEntity?.toBookDTO()
            else { throw MHError.convertDTOFailure }
            
            return .success(result)
        } catch {
            MHLogger.debug("Error fetching book: \(error.localizedDescription)")
            return .failure(.fetchFaliure)
        }
    }
    func update(with id: UUID, data: BookDTO) async -> Result<Void, MHError> {
        do {
            let context = coreDataStorage.persistentContainer.viewContext
            guard let newEntity = try getEntityByIdentifier(in: context, with: id) else {
                return .failure(.findEntityFailure)
            }
            newEntity.setValue(data.id, forKey: "id")
            newEntity.setValue(data.pages, forKey: "pages")
            
            await coreDataStorage.saveContext()
            return .success(())
        } catch {
            return .failure(.findEntityFailure)
        }
    }
    func delete(with id: UUID) async -> Result<Void, MHError> {
        do {
            let context = coreDataStorage.persistentContainer.viewContext
            guard let entity = try getEntityByIdentifier(in: context, with: id) else {
                return .failure(.findEntityFailure)
            }
            
            context.delete(entity)
            
            await coreDataStorage.saveContext()
            return .success(())
        } catch {
            return .failure(.findEntityFailure)
        }
    }
    
    private func getEntityByIdentifier(in context: NSManagedObjectContext, with id: UUID) throws -> BookEntity? {
        let request = BookEntity.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "id == %@", id as CVarArg
        )
        
        return try context.fetch(request).first
    }
}

extension BookEntity {
    func toBookDTO() -> BookDTO? {
        guard let id = self.id,
              let pages = self.pages else { return nil }
        
        return BookDTO(
            id: id,
            pages: pages
        )
    }
}
