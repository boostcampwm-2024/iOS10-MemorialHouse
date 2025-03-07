import MHCore
import MHDomain

public struct LocalMemorialHouseNameRepository: MemorialHouseNameRepository {
    private let storage: MemorialHouseNameStorage
    
    public init(storage: MemorialHouseNameStorage) {
        self.storage = storage
    }
    
    public func createMemorialHouseName(with name: String) async {
        await storage.create(with: name)
    }
    
    public func fetchMemorialHouseName() async throws -> String {
        return try await storage.fetch()
    }
}
