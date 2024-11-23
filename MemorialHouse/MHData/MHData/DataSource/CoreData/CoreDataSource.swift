import MHFoundation
import MHCore
import CoreData

final class BookCoverCoreDataSource: CoreDataSource {
    typealias DTO = BookCoverDTO
    
    // MARK: - Properties
    private let persistentContainer = PersistentContainerManager.shared.persistentContainer
    
    func fetch() async -> Result<[DTO], MHError> {
        let context = persistentContainer.newBackgroundContext()
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
    
    @discardableResult
    func create(data: DTO) async -> Result<Void, MHError> {
        let context = persistentContainer.newBackgroundContext()
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: "BookCoverEntity", into: context)
        newEntity.setValue(data.identifier, forKey: "identifier")
        newEntity.setValue(data.title, forKey: "title")
        newEntity.setValue(data.category, forKey: "category")
        newEntity.setValue(data.color, forKey: "color")
        newEntity.setValue(data.imageURL, forKey: "imageURL")
        newEntity.setValue(data.favorite, forKey: "favorite")
        
        return saveContext()
    }
    
    @discardableResult
    func update(with id: UUID, data: DTO) async -> Result<Void, MHError> {
        do {
            guard let newEntity = try getEntityByIdentifier(id) else { return .failure(.findEntityFailure) }
            newEntity.setValue(data.identifier, forKey: "identifier")
            newEntity.setValue(data.title, forKey: "title")
            newEntity.setValue(data.category, forKey: "category")
            newEntity.setValue(data.color, forKey: "color")
            newEntity.setValue(data.imageURL, forKey: "imageURL")
            newEntity.setValue(data.favorite, forKey: "favorite")
            
            return saveContext()
        } catch {
            return .failure(.findEntityFailure)
        }
    }
    
    @discardableResult
    func delete(with id: UUID) async -> Result<Void, MHError> {
        do {
            let context = persistentContainer.newBackgroundContext()
            guard let entity = try getEntityByIdentifier(id) else { return .failure(.findEntityFailure) }
            
            context.delete(entity)
            return saveContext()
        } catch {
            return .failure(.findEntityFailure)
        }
    }
    
    private func getEntityByIdentifier<Entity: NSManagedObject>(_ id: UUID) throws -> Entity? {
        let context = persistentContainer.newBackgroundContext()
        let request = Entity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "identifier = %@", id.uuidString)
        
        return try context.fetch(request).first as? Entity
    }
    
    private func saveContext() -> Result<Void, MHError> {
        let context = persistentContainer.newBackgroundContext()
        do {
            try context.save()
            
            return .success(())
        } catch {
            return .failure(.saveContextFailure)
        }
    }
}
