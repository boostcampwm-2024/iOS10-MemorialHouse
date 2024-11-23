import CoreData
import MHCore

actor PersistentContainerManager {
    static let shared = PersistentContainerManager()
    
    private init () { }
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MemorialHouseModel")
        container.loadPersistentStores { _, error in
            guard let error else { return }
            MHLogger.error("\(#function): PersistentContainer 호출에 실패; \(error.localizedDescription)")
        }
        
        return container
    }()
}
