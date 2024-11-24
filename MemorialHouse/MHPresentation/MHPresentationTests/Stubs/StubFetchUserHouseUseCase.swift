import MHDomain

public struct StubFetchUserHouseUseCase: FetchUserHouseUseCase {
    private var dummyUserHouse: UserHouse

    public init(dummyUserHouse: UserHouse) {
        self.dummyUserHouse = dummyUserHouse
    }
    
    public func execute() async -> UserHouse {
        return dummyUserHouse
    }
}
