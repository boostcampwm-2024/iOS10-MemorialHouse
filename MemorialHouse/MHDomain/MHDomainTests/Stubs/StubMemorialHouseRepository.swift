@testable import MHDomain

public struct StubMemorialHouseRepository: MemorialHouseRepository {
    private let dummyData: MemorialHouse
    
    public init(dummyData: MemorialHouse) {
        self.dummyData = dummyData
    }
    
    public func fetchMemorialHouse() async -> MemorialHouse {
        return dummyData
    }
}
