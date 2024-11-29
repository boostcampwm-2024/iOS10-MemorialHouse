import CoreData
import MHCore

public final class CoreDataStorage: Sendable {
    static let modelName: String = "MemorialHouseModel"
    
    nonisolated(unsafe) static let memorialHouseModel: NSManagedObjectModel = {
        guard let modelURL = Bundle(for: CoreDataStorage.self).url(
            forResource: CoreDataStorage.modelName,
            withExtension: "momd"
        ) else {
            fatalError("Error loading model from bundle")
        }
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    let persistentContainer: NSPersistentContainer
    
    public init() {
        let container = NSPersistentContainer(name: CoreDataStorage.modelName, managedObjectModel: Self.memorialHouseModel)
        container.loadPersistentStores { _, error in
            guard let error else { return }
            MHLogger.error("\(#function): PersistentContainer 호출에 실패; \(error.localizedDescription)")
        }
        self.persistentContainer = container
    }
    
    func saveContext() async {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                MHLogger.error("CoreDataStorage Error \(error.localizedDescription)")
            }
        }
    }
}
