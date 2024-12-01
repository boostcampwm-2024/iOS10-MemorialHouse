@testable import MHDomain

struct StubMemorialHouseRepository: MemorialHouseNameRepository {
    private let dummyData: MemorialHouse
    
    init(dummyData: MemorialHouse) {
        self.dummyData = dummyData
    }
    
    func fetchMemorialHouse() async -> Result<MemorialHouse, any Error> {
        return .success(dummyData)
    }
}
