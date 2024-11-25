import CoreData
import MHCore

public class CoreDataStorage {
    public static let modelName: String = "MemorialHouseModel"
    
    nonisolated(unsafe) public static let memorialHouseModel: NSManagedObjectModel = {
        guard let modelURL = Bundle(for: CoreDataStorage.self).url(
            forResource: CoreDataStorage.modelName,
            withExtension: "momd"
        ) else {
            fatalError("Error loading model from bundle")
        }
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataStorage.modelName)
        container.loadPersistentStores { _, error in
            guard let error else { return }
            MHLogger.error("\(#function): PersistentContainer 호출에 실패; \(error.localizedDescription)")
        }
        
        return container
    }()
    
    init() { }
    
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
