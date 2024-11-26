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
    func create(data: BookDTO) async -> Result<Void, MHCore.MHError> {
        let context = coreDataStorage.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "BookEntity", in: context) else {
            return .failure(.DIContainerResolveFailure(key: "BookEntity"))
        }
        
        let book = NSManagedObject(entity: entity, insertInto: context)
        book.setValue(data.id, forKey: "id")
        book.setValue(data.index, forKey: "index")
        book.setValue(data.pages, forKey: "pages")
        
        await coreDataStorage.saveContext()
        return .success(())
    }
    func fetch() async -> Result<BookDTO, MHCore.MHError> {
        let context = coreDataStorage.persistentContainer.viewContext
        let request = BookEntity.fetchRequest()
        
        do {
            let bookEntity = try context.fetch(request)
            guard let result = bookEntity.first?.toBookDTO()
            else { throw MHError.convertDTOFailure }
            
            return .success(result)
        } catch {
            MHLogger.debug("Error fetching book covers: \(error.localizedDescription)")
            return .failure(.convertDTOFailure)
        }
    }
    func update(with id: UUID, data: BookDTO) async -> Result<Void, MHCore.MHError> {
        do {
            let context = coreDataStorage.persistentContainer.viewContext
            guard let newEntity = try getEntityByIdentifier(in: context, with: id) else {
                return .failure(.findEntityFailure)
            }
            newEntity.setValue(data.id, forKey: "id")
            newEntity.setValue(data.index, forKey: "index")
            newEntity.setValue(data.pages, forKey: "pages")
            
            await coreDataStorage.saveContext()
            return .success(())
        } catch {
            return .failure(.findEntityFailure)
        }
    }
    func delete(with id: UUID) async -> Result<Void, MHCore.MHError> {
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
        
        return try context.fetch(request).first(where: { $0.id == id })
    }
}

extension BookEntity {
    func toBookDTO() -> BookDTO? {
        guard let id = self.id,
              let index = self.index,
              let pages = self.pages else { return nil }
        
        return BookDTO(
            id: id,
            index: index,
            pages: pages
        )
    }
}
