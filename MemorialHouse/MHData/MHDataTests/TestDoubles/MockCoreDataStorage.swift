@testable import MHData
@testable import MHCore
import CoreData

final class MockCoreDataStorage: CoreDataStorage {
    override init() {
        super.init()
        
        /// 해당 Container는 InMemory 타입이라는 것을 명시해줍니다.
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        /// 실제 사용하는 CoreDataStorage의 Model명과 NSManagedObjectModel을 가진 Container를 생성합니다.
        let container = NSPersistentContainer(
            name: CoreDataStorage.modelName,
            managedObjectModel: CoreDataStorage.memorialHouseModel
        )
        
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                MHLogger.error("\(#function): PersistentContainer 호출에 실패; \(error.localizedDescription)")
            }
        }
        persistentContainer = container
    }
}
