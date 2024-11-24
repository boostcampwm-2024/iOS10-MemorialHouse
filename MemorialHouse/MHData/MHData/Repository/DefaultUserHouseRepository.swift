import MHDomain

public struct DefaultUserHouseRepository: UserHouseRepository {
    public init() { }
    
    public func fetchUserHouse() async -> UserHouse {
        // TODO: CoreData로부터 꺼내오기
        return UserHouse(name: "", categories: [], bookCovers: [])
    }
}
