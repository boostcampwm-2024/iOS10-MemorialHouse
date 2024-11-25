import MHDomain

public struct StubFetchMemorialHouseUseCase: FetchMemorialHouseUseCase {
    private var dummyMemorialHouse: MemorialHouse

    public init(dummyMemorialHouse: MemorialHouse) {
        self.dummyMemorialHouse = dummyMemorialHouse
    }
    
    public func execute() async -> MemorialHouse {
        return dummyMemorialHouse
    }
}
