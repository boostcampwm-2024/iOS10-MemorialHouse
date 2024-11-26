import MHDomain

public struct DefaultMemorialHouseRepository: MemorialHouseRepository {
    public init() { }
    
    public func fetchMemorialHouse() async -> Result<MemorialHouse, Error> {
        // TODO: CoreData로부터 꺼내오기
        return .success(MemorialHouse(
            name: "효준",
            bookCovers: []
        ))
    }
}
