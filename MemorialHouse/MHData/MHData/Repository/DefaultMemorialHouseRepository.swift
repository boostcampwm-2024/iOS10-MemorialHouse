import MHDomain

public struct DefaultMemorialHouseRepository: MemorialHouseRepository {
    public init() { }
    
    public func fetchMemorialHouse() async -> MemorialHouse {
        // TODO: CoreData로부터 꺼내오기
        return MemorialHouse(
            name: "",
            bookCovers: []
        )
    }
}
