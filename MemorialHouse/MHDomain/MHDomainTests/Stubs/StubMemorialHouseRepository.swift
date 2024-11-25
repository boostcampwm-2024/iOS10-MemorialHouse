@testable import MHDomain

struct StubMemorialHouseRepository: MemorialHouseRepository {
    private let dummyData: MemorialHouse
    
    init(dummyData: MemorialHouse) {
        self.dummyData = dummyData
    }
    
    func fetchMemorialHouse() async -> MemorialHouse {
        return dummyData
    }
}
