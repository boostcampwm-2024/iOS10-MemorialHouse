public protocol MemorialHouseRepository: Sendable {
    func fetchMemorialHouse() async -> Result<MemorialHouse, Error>
}
