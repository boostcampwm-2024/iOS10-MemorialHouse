import CoreData
import MHCore

/// Core Data 스택을 구성하는 기본 클래스이며, 다른 코어데이터 구현체의 프로퍼티로 사용됩니다.
/// 또한, 테스트 환경에서 `MockCoreDataStorage`를 상속받아 확장할 수 있도록 설계되었습니다.
///
/// 이 클래스를 프로토콜로 작성하지 않은 이유는,
/// 테스트 코드에서도 `MemorialHouseModel`이라는 Core Data 모델을 동일하게 사용하기 위해서입니다.
/// 이를 통해 테스트 환경에서도 실제 DB 모델 구조를 유지하며 간단히 확장할 수 있습니다.
///
/// - 주요 특징:
///   - `NSPersistentContainer`를 활용해 Core Data 스택을 구성합니다.
///   - `saveContext` 메서드를 통해 변경된 컨텍스트를 저장합니다.
public class CoreDataStorage: @unchecked Sendable {
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
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataStorage.modelName, managedObjectModel: Self.memorialHouseModel)
        container.loadPersistentStores { _, error in
            guard let error else { return }
            MHLogger.error("\(#function): PersistentContainer 호출에 실패; \(error.localizedDescription)")
        }
        
        return container
    }()
    
    public init() { }
    
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
