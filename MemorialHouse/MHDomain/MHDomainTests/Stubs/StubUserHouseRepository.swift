@testable import MHDomain

public struct StubUserHouseRepository: UserHouseRepository {
    private let dummyData: UserHouse
    
    public init(dummyData: UserHouse) {
        self.dummyData = dummyData
    }
    
    public func fetchUserHouse() async -> UserHouse {
        return dummyData
    }
}
