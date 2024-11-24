public protocol MemorialHouseRepository: Sendable {
    func fetchMemorialHouse() async -> MemorialHouse
}
