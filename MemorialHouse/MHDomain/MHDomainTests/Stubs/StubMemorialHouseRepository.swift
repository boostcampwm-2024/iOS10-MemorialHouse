@testable import MHCore
@testable import MHDomain

struct StubMemorialHouseRepository: MemorialHouseNameRepository {
    private let dummyMemorialHouseName: String
    
    init(dummyMemorialHouseName: String) {
        self.dummyMemorialHouseName = dummyMemorialHouseName
    }
    
    func createMemorialHouseName(with name: String) async -> Result<Void, MHDataError> {
        .success(())
    }
    
    func fetchMemorialHouseName() async -> Result<String, MHDataError> {
        .success(dummyMemorialHouseName)
    }
}
