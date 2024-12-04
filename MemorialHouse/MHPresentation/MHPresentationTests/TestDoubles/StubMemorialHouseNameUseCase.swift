import MHDomain

struct StubCreateMemorialHouseNameUseCase: CreateMemorialHouseNameUseCase {
    func execute(with name: String) async throws { }
}

struct StubFetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase {
    private var dummyMemorialHouseName: String

    init(dummyMemorialHouseName: String) {
        self.dummyMemorialHouseName = dummyMemorialHouseName
    }
    
    func execute() async -> String {
        return dummyMemorialHouseName
    }
}
