import MHCore
import MHDomain

public struct LocalMemorialHouseNameRepository: MemorialHouseNameRepository {
    private let storage: MemorialHouseNameStorage
    
    public init(storage: MemorialHouseNameStorage) {
        self.storage = storage
    }
    
    public func createMemorialHouseName(with name: String) {
        storage.create(with: name)
    }
    
    public func fetchMemorialHouseName() throws -> String {
        return try storage.fetch()
    }
}
