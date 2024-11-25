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
    func create(data: BookCoverDTO) async -> Result<Void, MHError> {
        let context = coreDataStorage.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "BookCoverEntity", in: context) else {
            return .failure(.DIContainerResolveFailure(key: "BookCoverEntity"))
        }
        let bookCover = NSManagedObject(entity: entity, insertInto: context)
        bookCover.setValue(data.identifier, forKey: "identifier")
        bookCover.setValue(data.title, forKey: "title")
        bookCover.setValue(data.category, forKey: "category")
        bookCover.setValue(data.color, forKey: "color")
        bookCover.setValue(data.imageURL, forKey: "imageURL")
        bookCover.setValue(data.favorite, forKey: "favorite")
        
        await coreDataStorage.saveContext()
        return .success(())
    }
    
    func fetch() async -> Result<[BookCoverDTO], MHError> {
        let context = coreDataStorage.persistentContainer.viewContext
        let request = BookCoverEntity.fetchRequest()
        
        do {
            let bookCoverEntities = try context.fetch(request)
            let result = bookCoverEntities.compactMap { entity -> BookCoverDTO? in
                guard let identifier = entity.identifier,
                      let title = entity.title,
                      let color = entity.color else { return nil }
                
                return BookCoverDTO(
                    identifier: identifier,
                    title: title,
                    imageURL: entity.imageURL,
                    color: color,
                    category: entity.category,
                    favorite: entity.favorite
                )
            }
            
            return .success(result)
        } catch {
            MHLogger.debug("Error fetching book covers: \(error.localizedDescription)")
            return .failure(.convertDTOFailure)
        }
    }
    
    func update(with id: UUID, data: BookCoverDTO) async -> Result<Void, MHError> {
        do {
            let context = coreDataStorage.persistentContainer.viewContext
            guard let newEntity = try getEntityByIdentifier(in: context, with: id) else {
                return .failure(.findEntityFailure)
            }
            newEntity.setValue(data.identifier, forKey: "identifier")
            newEntity.setValue(data.title, forKey: "title")
            newEntity.setValue(data.category, forKey: "category")
            newEntity.setValue(data.color, forKey: "color")
            newEntity.setValue(data.imageURL, forKey: "imageURL")
            newEntity.setValue(data.favorite, forKey: "favorite")
            
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
    
    private func getEntityByIdentifier(in context: NSManagedObjectContext, with id: UUID) throws -> BookCoverEntity? {
        let request = BookCoverEntity.fetchRequest()
        
        return try context.fetch(request).first(where: { $0.identifier == id })
    }
}
