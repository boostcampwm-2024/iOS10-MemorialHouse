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
    func create(data: BookDTO) async -> Result<Void, MHCoreError> {
        let context = coreDataStorage.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "BookEntity", in: context) else {
            return .failure(.DIContainerResolveFailure(key: "BookEntity"))
        }
        
        let book = NSManagedObject(entity: entity, insertInto: context)
        book.setValue(data.id, forKey: "id")
        book.setValue(dtoPagesToCore(data.pages), forKey: "pages")
        
        await coreDataStorage.saveContext()
        return .success(())
    }
    func fetch(with id: UUID) async -> Result<BookDTO, MHDataError> {
        let context = coreDataStorage.persistentContainer.viewContext

        do {
            guard let bookEntity = try getEntityByIdentifier(in: context, with: id)
            else { return .failure(.findEntityFailure) }
            
            guard let result = coreBookToDTO(bookEntity)
            else { return .failure(.convertDTOFailure) }
            
            return .success(result)
        } catch {
            MHLogger.debug("Error fetching book: \(error.localizedDescription)")
            return .failure(.findEntityFailure)
        }
    }
    func update(with id: UUID, data: BookDTO) async -> Result<Void, MHDataError> {
        do {
            let context = coreDataStorage.persistentContainer.viewContext
            guard let newEntity = try getEntityByIdentifier(in: context, with: id) else {
                return .failure(.findEntityFailure)
            }
            newEntity.setValue(data.id, forKey: "id")
            newEntity.setValue(dtoPagesToCore(data.pages), forKey: "pages")
            
            await coreDataStorage.saveContext()
            return .success(())
        } catch {
            return .failure(.findEntityFailure)
        }
    }
    func delete(with id: UUID) async -> Result<Void, MHDataError> {
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

// MARK: - Mapper
extension CoreDataBookStorage {
    // MARK: - Core to DTO
    private func coreBookToDTO(_ book: BookEntity) -> BookDTO? {
        guard let id = book.id,
              let corePages = book.pages
        else { return nil }
        let pages = corePagesToDTO(corePages)
        
        return BookDTO(
            id: id,
            pages: pages
        )
    }
    private func corePagesToDTO(_ pages: NSOrderedSet) -> [PageDTO] {
        return pages.compactMap {
            guard let page = $0 as? PageEntity else { return nil }
            return corePageToDTO(page)
        }
    }
    private func corePageToDTO(_ page: PageEntity) -> PageDTO? {
        guard let id = page.id,
              let mediaDescriptions = page.mediaDescriptions,
              let text = page.text
        else { return nil }
        
        let metadata = mediaDescriptions.reduce(into: [Int: MediaDescriptionDTO]()) { partialResult, element in
            guard let element = element as? MediaDescriptionEntity else { return }
            guard let (index, mediaDescription) = coreMediaDescriptionToDTO(element) else { return }
            partialResult[index] = mediaDescription
        }
                
        return PageDTO(
            id: id,
            metadata: metadata,
            text: text
        )
    }
    private func coreMediaDescriptionToDTO(_ mediaDescription: MediaDescriptionEntity) -> (Int, MediaDescriptionDTO)? {
        guard let id = mediaDescription.id,
              let type = mediaDescription.type
        else { return nil }
        let location = mediaDescription.location
        return (Int(location), MediaDescriptionDTO(
            id: id,
            type: type,
            attributes: mediaDescription.attributes
        ))
    }
    
    // MARK: - DTO to Core
    private func dtoPagesToCore(_ pages: [PageDTO]) -> NSOrderedSet? {
        let context = coreDataStorage.persistentContainer.viewContext
        let pageEntities = pages.compactMap { dtoPageToCore($0, in: context) }
        return NSOrderedSet(array: pageEntities)
    }
    private func dtoPageToCore(_ page: PageDTO, in context: NSManagedObjectContext) -> PageEntity? {
        guard let entity = NSEntityDescription.insertNewObject(
            forEntityName: "PageEntity",
            into: context
        ) as? PageEntity else {
            return nil
        }
        
        entity.id = page.id
        entity.text = page.text
        entity.mediaDescriptions = dtoMediaDescriptionsToCore(page.metadata, in: context)
        
        return entity
    }
    private func dtoMediaDescriptionsToCore(
        _ metadata: [Int: MediaDescriptionDTO],
        in context: NSManagedObjectContext
    ) -> NSSet? {
        let mediaDescriptionEntities = metadata.compactMap { location, description in
            dtoMediaDescriptionToCore(location: location, description, in: context)
        }
        return NSSet(array: mediaDescriptionEntities)
    }
    private func dtoMediaDescriptionToCore(
        location: Int,
        _ mediaDescription: MediaDescriptionDTO,
        in context: NSManagedObjectContext
    ) -> MediaDescriptionEntity? {
        guard let entity = NSEntityDescription.insertNewObject(
            forEntityName: "MediaDescriptionEntity",
            into: context
        ) as? MediaDescriptionEntity else {
            return nil
        }
        
        entity.id = mediaDescription.id
        entity.type = mediaDescription.type
        entity.attributes = mediaDescription.attributes
        entity.location = Int64(location)
        
        return entity
    }
}
