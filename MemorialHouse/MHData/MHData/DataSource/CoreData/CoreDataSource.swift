import MHFoundation
import MHCore
import CoreData

final class CoreDataSource {
    // MARK: - Properties
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MemorialHouseModel")
        container.loadPersistentStores { _, error in
            guard let error else { return }
            MHLogger.error("\(#function): PersistentContainer 호출에 실패; \(error.localizedDescription)")
        }
        
        return container
    }()
    
    func fetch<Entity: NSManagedObject>() async -> Result<[Entity], MHError> {
        let context = persistentContainer.newBackgroundContext()
        let request = Entity.fetchRequest()
        
        do {
            guard let result = try context.fetch(request) as? [Entity] else { return .failure(.convertDTOFailure)}
            
            return .success(result)
        } catch {
            MHLogger.debug("Error fetching book covers: \(error.localizedDescription)")
            return .failure(.convertDTOFailure)
        }
    }
    
    func create<Entity: NSManagedObject>(entity: Entity) async -> Result<Void, MHError> {
        let context = persistentContainer.newBackgroundContext()
        var newEntity = Entity(context: context)
        newEntity = entity
        
        return saveContext()
    }
    
    func update<Entity: NSManagedObject>(with id: UUID, entity: Entity) async -> Result<Void, MHError> {
        
    }
    
    func delete(with id: UUID) async -> Result<Void, MHError> {
        do {
            let context = persistentContainer.newBackgroundContext()
            guard let entity = try getEntityByIdentifier(id) else { return .failure(.findEntityFailure) }
            
            context.delete(entity)
            return saveContext()
        } catch {
            return .failure(.saveContextFailure)
        }
    }
    
    private func getEntityByIdentifier(_ id: UUID) throws -> BookCoverEntity? {
        let request = BookCoverEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "identifier = %@", id.uuidString)
        
        return try context.fetch(request).first
    }
    
    private func saveContext() -> Result<Void, MHError> {
        do {
            try context.save()
            
            return .success(())
        } catch {
            return .failure(.saveContextFailure)
        }
    }
}
