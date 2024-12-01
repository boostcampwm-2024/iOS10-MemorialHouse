import MHCore
import MHDomain

public struct LocalMemorialHouseNameRepository: MemorialHouseNameRepository {
    private let storage: MemorialHouseNameStorage
    
    public init(storage: MemorialHouseNameStorage) {
        self.storage = storage
    }
    
    public func createMemorialHouseName(with name: String) async -> Result<Void, MHDataError> {
        return await storage.create(with: name)
    }
    
    public func fetchMemorialHouseName() async -> Result<String, MHDataError> {
        return await storage.fetch()
    }
}
